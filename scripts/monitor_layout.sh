#!/usr/bin/env bash
set -euo pipefail
sleep 1

# Detect displays
internal_output=$(wlr-randr | grep -E 'eDP|LVDS' | awk '{print $1}' | head -n1 || true)
external_output=$(wlr-randr | grep -E '^DP-|^HDMI' | awk '{print $1}' | head -n1 || true)

# Helper to find best mode
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

# Menu labels
options="External only\nMirror\nExtend\nCancel"

# Pick mode: use rofi if no argument supplied
if [[ $# -eq 0 ]]; then
    if command -v rofi >/dev/null 2>&1; then
        choice=$(printf "$options" | rofi -dmenu -p "Display mode:" -theme ~/.config/mango/rofi/gruvbox-dark-hard.rasi)
    elif command -v wofi >/dev/null 2>&1; then
        choice=$(printf "$options" | wofi --dmenu -p "Display mode:" -theme ~/.config/rofi/themes/gruvbox-dark-hard.rasi)
    else
        echo "Rofi/Wofi not found. Use argument: external|mirror|extend"
        exit 1
    fi
else
    choice=$1
fi

case "$choice" in
    "External only"|"external"|"1")
        echo "→ External only"
        [ -n "$internal_output" ] && wlr-randr --output "$internal_output" --off || true
        wlr-randr --output "$external_output" --mode "$best_external_mode" --pos 0,0 --scale 1
        ;;
    "Mirror"|"mirror"|"2")
        echo "→ Mirroring displays"
        wlr-randr --output "$external_output" --mode "$best_external_mode" --pos 0,0 --scale 1
        wlr-randr --output "$internal_output" --mode "$best_internal_mode" --pos 0,0 --scale 1
        ;;
    "Extend"|"extend"|"3")
        echo "→ Extending (external right)"
        internal_width=$(echo "$best_internal_mode" | cut -dx -f1)
        wlr-randr --output "$internal_output" --mode "$best_internal_mode" --pos 0,0 --scale 2
        wlr-randr --output "$external_output" --mode "$best_external_mode" --pos "${internal_width},0" --scale 1
        ;;
    "Cancel"|*)
        echo "Cancelled."
        ;;
esac

