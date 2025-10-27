#!/usr/bin/env bash
set -euo pipefail
sleep 1

internal_output=$(wlr-randr | grep -E 'eDP|LVDS' | awk '{print $1}' | head -n1 || true)
external_output=$(wlr-randr | grep -E '^DP-|^HDMI' | awk '{print $1}' | head -n1 || true)

get_best_mode() {
    local output=$1
    wlr-randr --output "$output" |
        grep -Eo '[0-9]+x[0-9]+ px, [0-9.]+ Hz' |
        sed -E 's/ px, ([0-9.]+) Hz/@\1Hz/' |
        sort -t '@' -k2,2nr |
        head -n1
}

best_internal_mode=$(get_best_mode "$internal_output" 2>/dev/null || true)
best_external_mode=$(get_best_mode "$external_output" 2>/dev/null || true)

# Choose layout (CLI argument or menu)
mode="${1:-menu}"
if [[ "$mode" == "menu" ]]; then
    echo "Select display mode:"
    echo "1) External only"
    echo "2) Mirror"
    echo "3) Extend"
    read -rp "> " choice
else
    choice="$mode"
fi

case "$choice" in
    1|"external")
        echo "→ External only"
        [ -n "$internal_output" ] && wlr-randr --output "$internal_output" --off || true
        wlr-randr --output "$external_output" --mode "$best_external_mode" --pos 0,0 --scale 1
        ;;
    2|"mirror")
        echo "→ Mirroring displays"
        wlr-randr --output "$external_output" --mode "$best_external_mode" --pos 0,0 --scale 1
        wlr-randr --output "$internal_output" --mode "$best_internal_mode" --pos 0,0 --scale 1
        ;;
    3|"extend")
        echo "→ Extending (external on right)"
        internal_width=$(echo "$best_internal_mode" | cut -dx -f1)
        wlr-randr --output "$internal_output" --mode "$best_internal_mode" --pos 0,0 --scale 2
        wlr-randr --output "$external_output" --mode "$best_external_mode" --pos "${internal_width},0" --scale 1
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac

