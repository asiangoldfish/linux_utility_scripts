#!/usr/bin/bash

MONITOR_INTERFACE="eDP"

IFS=': ' read -ra numbers <<< "$(xrandr --listactivemonitors | grep 'Monitors')"
if [[ "${numbers[1]}" -gt 1 ]]; then
    xrandr --output "$MONITOR_INTERFACE" --off
fi
