#!/usr/bin/env bash
set -euo pipefail

sleep 1  # allow compositor to register outputs

# Extract the names of all enabled outputs
outputs=$(wlr-randr | grep '^[A-Za-z0-9-]\+ "' | awk '{print $1}')

if echo "$outputs" | grep -q "^DP-1$"; then
    echo "External monitor DP-1 detected → enabling it only"
    wlr-randr --output eDP-1 --off
    wlr-randr --output DP-1 --mode 5120x2880 --pos 0,0 --scale 2
else
    echo "External monitor not found → using laptop screen"
    wlr-randr --output eDP-1 --mode 1920x1200 --pos 0,0 --scale 1
fi

