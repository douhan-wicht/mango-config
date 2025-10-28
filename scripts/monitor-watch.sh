#!/usr/bin/env bash
set -euo pipefail

last_state=""

while true; do
  current_state=$(wlr-randr | grep -E '^[A-Z]+-[0-9]+"' | sort)
  if [[ "$current_state" != "$last_state" ]]; then
    echo "Display setup changed → reapplying layout"
    ~/.config/mango/scripts/monitor.sh
    last_state="$current_state"
  fi
  sleep 2
done

