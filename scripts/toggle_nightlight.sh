#!/usr/bin/env bash

# Check if wlsunset is running
if pgrep -x "wlsunset" > /dev/null
then
    # If it's running, kill it (turn off night light)
    pkill wlsunset
else
    # If it's not running, start it (turn on night light)
    wlsunset -T 3501 -t 3500 >/dev/null 2>&1 &
fi
