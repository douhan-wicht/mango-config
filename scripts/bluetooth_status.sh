#!/usr/bin/env bash

# Bluetooth indicator for Waybar / MangoWC

status=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

case "$1" in
  "toggle")
    if [ "$status" = "yes" ]; then
      bluetoothctl power off
      notify-send "Bluetooth" "Powered Off"
    else
      bluetoothctl power on
      notify-send "Bluetooth" "Powered On"
    fi
    ;;
  *)
    if [ "$status" = "yes" ]; then
      echo ""   # Bluetooth On
    else
      echo ""   # Bluetooth Off
    fi
    ;;
esac

