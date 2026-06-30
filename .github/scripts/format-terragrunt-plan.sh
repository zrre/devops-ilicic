#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-unknown}"
PLAN_FILE="${2:-plan.txt}"
OUTPUT_FILE="${3:-plan-comment.md}"

MAX_CHARS_PER_UNIT=25000
MAX_CHARS_FULL=60000

UNITS=("resource-group" "network" "private-services" "test-vm")

if [ ! -f "$PLAN_FILE" ]; then
  cat > "$OUTPUT_FILE" <<EOF
## Terragrunt plan: \`${ENVIRONMENT}\`

Plan output file was not found: \`${PLAN_FILE}\`
EOF
  exit 0
fi

PLAN_CONTENT="$(cat "$PLAN_FILE")"

# Remove ANSI color codes
PLAN_CONTENT="$(printf "%s" "$PLAN_CONTENT" | sed -E 's/\x1b\[[0-9;]*m//g')"

extract_unit_output() {
  local unit="$1"

  # Terragrunt prefixes output lines with [unit]
  printf "%s\n" "$PLAN_CONTENT" | grep -E "^\[[^]]*${unit}[^]]*\]" || true
}

unit_result() {
  local unit="$1"
  local unit_output
  unit_output="$(extract_unit_output "$unit")"

  if printf "%s" "$unit_output" | grep -q "No changes."; then
    echo "No changes"
  elif printf "%s" "$unit_output" | grep -Eq "Plan: [0-9]+ to add, [0-9]+ to change, [0-9]+ to destroy"; then
    printf "%s" "$unit_output" \
      | grep -Eo "Plan: [0-9]+ to add, [0-9]+ to change, [0-9]+ to destroy" \
      | tail -1
  elif printf "%s" "$unit_output" | grep -qi "error"; then
    echo "Error"
  elif [ -z "$unit_output" ]; then
    echo "No output found"
  else
    echo "Review output"
  fi
}

overall_result() {
  if grep -qi "error" <<< "$PLAN_CONTENT"; then
    echo "Plan failed or contains errors"
  elif grep -Eq "Plan: [1-9][0-9]* to add|Plan: [0-9]+ to add, [1-9][0-9]* to change|Plan: [0-9]+ to add, [0-9]+ to change, [1-9][0-9]* to destroy" <<< "$PLAN_CONTENT"; then
    echo "Changes detected"
  elif grep -q "No changes." <<< "$PLAN_CONTENT"; then
    echo "No infrastructure changes detected"
  else
    echo "Plan completed, review output below"
  fi
}

write_limited_block() {
  local content="$1"
  local limit="$2"

  local size
  size="$(wc -c <<< "$content" | tr -d ' ')"

  if [ "$size" -gt "$limit" ]; then
    python3 - "$limit" <<< "$content" <<'PY'
import sys

limit = int(sys.argv[1])
content = sys.stdin.read()
sys.stdout.write(content[:limit])
PY
    echo
    echo
    echo "... output truncated. Check GitHub Actions logs for the full output."
  else
    printf "%s" "$content"
  fi
}

{
  echo "## Terragrunt plan: \`${ENVIRONMENT}\`"
  echo
  echo "**Result:** $(overall_result)"
  echo
  echo "### Summary"
  echo
  echo "| Unit | Result |"
  echo "|---|---|"

  for unit in "${UNITS[@]}"; do
    echo "| \`${unit}\` | $(unit_result "$unit") |"
  done

  echo
  echo "### Unit details"
  echo

  for unit in "${UNITS[@]}"; do
    unit_output="$(extract_unit_output "$unit")"
    result="$(unit_result "$unit")"

    echo "<details>"
    echo "<summary><strong>${unit}</strong> — ${result}</summary>"
    echo
    echo '```text'

    if [ -n "$unit_output" ]; then
      write_limited_block "$unit_output" "$MAX_CHARS_PER_UNIT"
    else
      echo "No output found for unit: ${unit}"
    fi

    echo
    echo '```'
    echo
    echo "</details>"
    echo
  done

  echo "<details>"
  echo "<summary><strong>Full raw Terragrunt plan output</strong></summary>"
  echo
  echo '```text'
  write_limited_block "$PLAN_CONTENT" "$MAX_CHARS_FULL"
  echo
  echo '```'
  echo
  echo "</details>"
} > "$OUTPUT_FILE"