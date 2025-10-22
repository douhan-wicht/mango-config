#!/usr/bin/env bash

# Power Profile Switcher (MangoWC-friendly version)

get_current_profile() {
  if command -v powerprofilesctl &>/dev/null; then
    powerprofilesctl get
  else
    echo "power-saver"
  fi
}

set_profile() {
  local mode="$1"
  if command -v powerprofilesctl &>/dev/null; then
    powerprofilesctl set "$mode"
    notify-send "Power Profile" "Switched to: $mode"
  fi
}

toggle_profile() {
  local current
  current=$(get_current_profile)
  case $current in
    "power-saver") set_profile "balanced" ;;
    "balanced") set_profile "performance" ;;
    "performance") set_profile "power-saver" ;;
  esac
}

display_profile() {
  local current
  current=$(get_current_profile)
  case $current in
    "power-saver") echo "󰾆" ;; # Battery icon
    "balanced")    echo "󰾅" ;; # Balanced
    "performance") echo "󰓅" ;; # Rocket
  esac
}

case "$1" in
  "toggle")   toggle_profile ;;
  "display")  display_profile ;;
  *)          display_profile ;;
esac

