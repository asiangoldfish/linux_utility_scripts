#!/usr/bin/bash

function main() {

    # Iterate all lines to find the Touchpad, if the device is supported
    if ! xinput list | grep -q "Touchpad"; then
        echo "Unable to find a supported touchpad. Nothing was changed."
        exit 1
    fi

    # Find the device id. Call it by using the following syntax:
    # ${found_id[1]}
    local IFS
    IFS='=' read -ra found_id <<< "$( xinput list | grep "Touchpad" | awk '{print $6}' )"
    local id="${found_id[1]}"

    # Check if device is enabled. The value is inverted, so invert before using it
    local isDeviceEnabled="$( xinput list-props $id | grep "Device Enabled" | awk '{print $4}' )"
    
    # Set new state. It's the inverse of the current
    local newState
    if [ "$isDeviceEnabled" == "0" ]; then
        newState=1
        echo "Touchpad is enabled"
    else
        newState=0
        echo "Touchpad is disabled"
    fi
    

    # Toggle touchpad
    xinput set-prop "$id" "Device Enabled" "$newState"
}

main