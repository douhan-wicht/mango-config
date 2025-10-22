#!/usr/bin/env bash

# Theme Switcher Script for MangoWC / Sway environments

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CURRENT_WALLPAPER_FILE="$HOME/.cache/current_wallpaper"

# Collect wallpapers
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sort)

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
  notify-send "Theme Switcher" "No wallpapers found in $WALLPAPER_DIR"
  exit 1
fi

# Helpers
get_current_index() {
  [[ -f "$CURRENT_WALLPAPER_FILE" ]] && cat "$CURRENT_WALLPAPER_FILE" || echo "0"
}

apply_theme() {
  local wallpaper_path="$1"
  local index="$2"
  local wallpaper_name
  wallpaper_name=$(basename "$wallpaper_path")

  echo "$index" >"$CURRENT_WALLPAPER_FILE"

  # Kill existing swaybg (to avoid multiple instances)
  pkill swaybg 2>/dev/null || true

  # Start new swaybg process with selected wallpaper
  swaybg -i "$wallpaper_path" -m fill &

  update_swaylock_wallpaper "$wallpaper_path"
  notify-send "Theme Switcher" "Applied: $wallpaper_name"
}

update_swaylock_wallpaper() {
  local wallpaper_path="$1"
  local swaylock_config="$HOME/.config/swaylock/config"

  mkdir -p "$(dirname "$swaylock_config")"

  # Create config if missing
  if [[ ! -f "$swaylock_config" ]]; then
    echo "image=$wallpaper_path" > "$swaylock_config"
    return
  fi

  # Replace or add image line
  if grep -q "^image=" "$swaylock_config"; then
    sed -i "s|^image=.*|image=$wallpaper_path|" "$swaylock_config"
  else
    echo "image=$wallpaper_path" >> "$swaylock_config"
  fi
}

restore_theme() {
  local index
  index=$(get_current_index)
  apply_theme "${WALLPAPERS[$index]}" "$index"
}

# Main
case "${1:-next}" in
"next")
  next_index=$((($(get_current_index) + 1) % ${#WALLPAPERS[@]}))
  apply_theme "${WALLPAPERS[$next_index]}" "$next_index"
  ;;
"random")
  random_index=$((RANDOM % ${#WALLPAPERS[@]}))
  apply_theme "${WALLPAPERS[$random_index]}" "$random_index"
  ;;
"restore")
  restore_theme
  ;;
"list")
  # Show only filenames in rofi (instead of wofi)
  selected=$(printf "%s\n" "${WALLPAPERS[@]##*/}" | rofi -dmenu -p "Choose Wallpaper")

  if [ -n "$selected" ]; then
    for i in "${!WALLPAPERS[@]}"; do
      if [[ "${WALLPAPERS[$i]##*/}" == "$selected" ]]; then
        apply_theme "${WALLPAPERS[$i]}" "$i"
        break
      fi
    done
  else
    notify-send "Theme Switcher" "No wallpaper selected."
  fi
  ;;
esac

