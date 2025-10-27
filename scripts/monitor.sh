#!/usr/bin/env bash
set -euo pipefail

sleep 1  # let compositor settle

# Check if external monitor is connected
if wlr-randr | grep -q '^DP-1 "'; then
    echo "External monitor DP-1 detected → enabling it only"

    # Pick the mode with the highest refresh rate automatically
    best_mode=$(wlr-randr --output DP-1 | awk '/px,/{print $1, $3}' | sort -k2,2nr | head -n1 | awk '{print $1"@"$2}')
    echo "Using best mode for DP-1: $best_mode"

    # Disable laptop screen if present
    internal_output=$(wlr-randr | grep -E 'eDP|LVDS' | awk '{print $1}' | head -n1 || true)
    [ -n "${internal_output:-}" ] && wlr-randr --output "$internal_output" --off || true

    # Apply the mode
    wlr-randr --output DP-1 --mode "$best_mode" --pos 0,0 --scale 1
else
    echo "External monitor not found → using internal screen"
    internal_output=$(wlr-randr | grep -E 'eDP|LVDS' | awk '{print $1}' | head -n1)
    best_mode=$(wlr-randr --output "$internal_output" | awk '/px,/{print $1, $3}' | sort -k2,2nr | head -n1 | awk '{print $1"@"$2}')
    wlr-randr --output "$internal_output" --mode "$best_mode" --pos 0,0 --scale 1
fi

