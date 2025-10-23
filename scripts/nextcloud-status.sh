#!/usr/bin/env bash
set -euo pipefail

CFG="$HOME/.config/Nextcloud/nextcloud.cfg"
LOGDIR="$HOME/.config/Nextcloud"

# --- 1. Process detection ---
alive=false
for p in /proc/[0-9]*; do
  [[ -r "$p/comm" ]] || continue
  read -r name < "$p/comm" || continue
  case "$name" in
    nextcloud|.nextcloud-wrap)
      # Skip zombies
      if ! grep -q "State:.*Z" "$p/status" 2>/dev/null; then
        alive=true
        break
      fi
      ;;
  esac
done

if [[ "$alive" == false ]]; then
  echo "error"
  exit 0
fi

# --- 2. Inactive check ---
if [[ ! -f "$CFG" ]]; then
  echo "inactive"
  exit 0
fi

has_accounts=$(grep -aiE 'Accounts\\[0-9]+\\(url|dav_user|user)' "$CFG" || true)
has_folders=$(grep -aiE 'Folders\\[0-9]+\\localpath' "$CFG" || true)
if [[ -z "$has_accounts" && -z "$has_folders" ]]; then
  echo "inactive"
  exit 0
fi

# --- 3. Paused check ---
total=$(grep -aiE '^[0-9]+\\Folders\\[0-9]+\\paused=' "$CFG" | wc -l || true)
paused=$(grep -aiE '^[0-9]+\\Folders\\[0-9]+\\paused=true' "$CFG" | wc -l || true)
if [[ "$total" -gt 0 && "$paused" -eq "$total" ]]; then
  echo "paused"
  exit 0
fi

# --- 4. Sync detection ---
shopt -s nullglob
logs=( "$LOGDIR"/*_sync.log )
latest_started=""
latest_finished=""

for f in "${logs[@]}"; do
  s=$(grep -a "#=#=#=# Syncrun started" "$f" | tail -n1 | sed -E 's/.* ([0-9T:\-]+)Z.*/\1/')
  e=$(grep -a "#=#=#=# Syncrun finished" "$f" | tail -n1 | sed -E 's/.* ([0-9T:\-]+)Z.*/\1/')
  [[ -n "$s" && ( -z "$latest_started" || "$s" > "$latest_started" ) ]] && latest_started="$s"
  [[ -n "$e" && ( -z "$latest_finished" || "$e" > "$latest_finished" ) ]] && latest_finished="$e"
done

if [[ -n "$latest_started" && ( -z "$latest_finished" || "$latest_started" > "$latest_finished" ) ]]; then
  echo "sync"
else
  echo "ok"
fi

