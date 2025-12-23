#!/usr/bin/env bash
# Simple Interest Calculator
# Usage:
#   ./simple-interest.sh <principal> <rate> <time>
# If any arguments are missing, you will be prompted interactively.
# rate is in percent per time period (e.g., annual rate if time is in years).

set -euo pipefail

err() { printf "Error: %s\n" "$*" >&2; }

read_or_arg() {
  local varname="$1" prompt="$2" value="${3:-}"
  if [ -z "${value}" ]; then
    read -r -p "$prompt: " value
  fi
  printf "%s" "${value}"
}

is_number() {
  local re='^[-+]?[0-9]*\.?[0-9]+$'
  [[ "$1" =~ $re ]]
}

main() {
  principal=$(read_or_arg principal "Enter principal" "${1:-}")
  rate=$(read_or_arg rate "Enter rate (percent)" "${2:-}")
  time=$(read_or_arg time "Enter time period" "${3:-}")

  for pair in \
    "principal:$principal" \
    "rate:$rate" \
    "time:$time"; do
    key=${pair%%:*}; val=${pair#*:}
    if ! is_number "$val"; then err "$key must be numeric"; exit 1; fi
    awk "BEGIN {if ($val < 0) exit 1}" || { err "$key must be non-negative"; exit 1; }
  done

  interest=$(awk "BEGIN { printf \"%.2f\", ($principal * $rate * $time) / 100 }")
  total=$(awk "BEGIN { printf \"%.2f\", $principal + ($principal * $rate * $time) / 100 }")

  printf "Principal: %s\n" "$principal"
  printf "Rate (%%): %s\n" "$rate"
  printf "Time: %s\n" "$time"
  printf "Simple Interest: %s\n" "$interest"
  printf "Total Amount: %s\n" "$total"
}

main "$@"
