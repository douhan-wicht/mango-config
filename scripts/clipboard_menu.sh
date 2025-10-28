#!/usr/bin/env bash

# Clipboard History Picker for MangoWC (Wayland + Rofi)

selection=$(cliphist list | rofi -dmenu -p "Clipboard History" -width 70 -lines 15 -theme ~/.config/mango/rofi/gruvbox-dark-hard.rasi)

if [ -n "$selection" ]; then
  cliphist decode <<< "$selection" | wl-copy
else
  notify-send "Clipboard" "No item selected"
fi

