#!/usr/bin/env bash

# Clipboard History Picker for MangoWC (Wayland + Rofi)

selection=$(cliphist list | rofi -dmenu -p "Clipboard History" -width 70 -lines 15)

if [ -n "$selection" ]; then
  cliphist decode <<< "$selection" | wl-copy
else
  notify-send "Clipboard" "No item selected"
fi

