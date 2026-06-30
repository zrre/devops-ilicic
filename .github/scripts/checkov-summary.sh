#!/usr/bin/env bash
set -euo pipefail

TITLE="$1"
RESULT_FILE="$2"
OUTPUT_FILE="$3"

{
  echo "## ${TITLE}"
  echo

  if [ ! -s "$RESULT_FILE" ]; then
    echo "No Checkov output found."
    exit 0
  fi

  FAILED_COUNT="$(grep -c '^FAILED for resource:' "$RESULT_FILE" || true)"
  PASSED_COUNT="$(grep -c '^PASSED for resource:' "$RESULT_FILE" || true)"
  SKIPPED_COUNT="$(grep -c '^SKIPPED for resource:' "$RESULT_FILE" || true)"

  echo "| Result | Count |"
  echo "|---|---:|"
  echo "| Failed | ${FAILED_COUNT} |"
  echo "| Passed | ${PASSED_COUNT} |"
  echo "| Skipped | ${SKIPPED_COUNT} |"
  echo

  if [ "$FAILED_COUNT" -gt 0 ]; then
    echo "### Failed checks"
    echo
    echo '```text'
    grep -E '^(Check:|FAILED for resource:|File:)' "$RESULT_FILE" | head -n 120 || true
    echo '```'
    echo
  fi

  echo "<details>"
  echo "<summary>Full Checkov output</summary>"
  echo
  echo '```text'
  head -n 400 "$RESULT_FILE" || true
  echo '```'
  echo
  echo "</details>"
} > "$OUTPUT_FILE"
