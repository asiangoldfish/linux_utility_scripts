#!/usr/bin/bash

# Iterate all lines to find the Touchpad, if the device is supported
if ! xinput list | grep -q "Touchpad"; then
    echo "Touchpad is not supported"
    exit 1
fi

# Find the device id. Call it by using the following syntax:
# ${found_id[1]}
IFS='=' read -ra found_id <<< "$( xinput list | grep "Touchpad" | awk '{print $6}' )"
id="${found_id[1]}"

# Check if device is enabled. The value is inverted, so invert before using it
isDeviceEnabled="$( xinput list-props 11 | grep "Device Enabled" | awk '{print $4}' )"

if [[ "$isDeviceEnabled" -eq 0 ]]; then
    xinput set-prop "$id" "Device Enabled" 1
    echo "Touchpad enabled"
else
    xinput set-prop "$id" "Device Enabled" 0
    echo "Touchpad disabled"
fi