#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-unknown}"
PLAN_FILE="${2:-plan.txt}"
OUTPUT_FILE="${3:-plan-comment.md}"

MAX_CHARS=60000

if [ ! -f "$PLAN_FILE" ]; then
  cat > "$OUTPUT_FILE" <<EOF
## Terragrunt plan: \`${ENVIRONMENT}\`

Plan output file was not found: \`${PLAN_FILE}\`
EOF
  exit 0
fi

PLAN_CONTENT="$(cat "$PLAN_FILE")"

# Remove ANSI color codes just in case
PLAN_CONTENT="$(printf "%s" "$PLAN_CONTENT" | sed -E 's/\x1b\[[0-9;]*m//g')"

HAS_CHANGES="false"
if printf "%s" "$PLAN_CONTENT" | grep -Eq "Plan: [0-9]+ to add, [0-9]+ to change, [0-9]+ to destroy"; then
  HAS_CHANGES="true"
fi

{
  echo "## Terragrunt plan: \`${ENVIRONMENT}\`"
  echo

  if [ "$HAS_CHANGES" = "true" ]; then
    echo "**Result:** Changes detected"
  elif printf "%s" "$PLAN_CONTENT" | grep -q "No changes."; then
    echo "**Result:** No infrastructure changes detected"
  else
    echo "**Result:** Plan completed, review output below"
  fi

  echo
  echo "### Summary"
  echo
  echo "| Unit | Result |"
  echo "|---|---|"

  for unit in resource-group network private-services test-vm; do
    unit_lines="$(printf "%s" "$PLAN_CONTENT" | grep -E "\[$unit\]" || true)"

    if printf "%s" "$unit_lines" | grep -q "No changes."; then
      echo "| \`$unit\` | No changes |"
    elif printf "%s" "$unit_lines" | grep -Eq "Plan: [0-9]+ to add, [0-9]+ to change, [0-9]+ to destroy"; then
      summary="$(printf "%s" "$unit_lines" | grep -Eo "Plan: [0-9]+ to add, [0-9]+ to change, [0-9]+ to destroy" | tail -1)"
      echo "| \`$unit\` | $summary |"
    elif printf "%s" "$unit_lines" | grep -qi "error"; then
      echo "| \`$unit\` | Error, check full plan |"
    else
      echo "| \`$unit\` | See full output |"
    fi
  done

  echo
  echo "<details>"
  echo "<summary>Full Terragrunt plan output</summary>"
  echo
  echo '```text'

  printf "%s" "$PLAN_CONTENT" | head -c "$MAX_CHARS"

  if [ "$(printf "%s" "$PLAN_CONTENT" | wc -c | tr -d ' ')" -gt "$MAX_CHARS" ]; then
    echo
    echo
    echo "... output truncated. Check GitHub Actions logs for the full plan."
  fi

  echo
  echo '```'
  echo
  echo "</details>"
} > "$OUTPUT_FILE"
