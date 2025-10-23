#!/usr/bin/env bash
set -euo pipefail

CFG="$HOME/.config/Nextcloud/nextcloud.cfg"
LOGDIR="$HOME/.config/Nextcloud"

# 1) Check if Nextcloud is running (handles .nextcloud-wrap)
if ! pgrep -f '[.]?nextcloud' >/dev/null; then
  echo "error"
  exit 0
fi

# 2) Check if *all* folders are paused
is_paused() {
  [[ -f "$CFG" ]] || return 1
  local total paused
  total=$(grep -aiE '^[0-9]+\\Folders\\[0-9]+\\paused=' "$CFG" | wc -l | tr -d ' ')
  paused=$(grep -aiE '^[0-9]+\\Folders\\[0-9]+\\paused=true' "$CFG" | wc -l | tr -d ' ')
  if [[ "$total" -gt 0 && "$paused" -eq "$total" ]]; then
    return 0
  fi
  return 1
}

if is_paused; then
  echo "paused"
  exit 0
fi

# 3) Check logs for sync/ok state
latest_started=""
latest_finished=""

shopt -s nullglob
logs=( "$LOGDIR"/*_sync.log )
if ((${#logs[@]} == 0)); then
  echo "ok"
  exit 0
fi

for f in "${logs[@]}"; do
  s=$(grep -a "#=#=#=# Syncrun started" "$f" | tail -n1 | sed -E 's/.* ([0-9T:\-]+)Z.*/\1/')
  e=$(grep -a "#=#=#=# Syncrun finished" "$f" | tail -n1 | sed -E 's/.* ([0-9T:\-]+)Z.*/\1/')
  [[ -n "$s" ]] && { [[ -z "$latest_started" || "$s" > "$latest_started" ]] && latest_started="$s"; }
  [[ -n "$e" ]] && { [[ -z "$latest_finished" || "$e" > "$latest_finished" ]] && latest_finished="$e"; }
done

if [[ -n "$latest_started" && ( -z "$latest_finished" || "$latest_started" > "$latest_finished" ) ]]; then
  echo "sync"
else
  echo "ok"
fi

