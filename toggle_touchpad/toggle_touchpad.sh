#!/usr/bin/bash

function main() {

    STATE_FILE="$HOME/.touchpad_toggle"     # File to store state in
    STATE="$( cat "$STATE_FILE" || echo 1 )"          # Touchpad ON/OFF state
    
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
    #isDeviceEnabled="$( xinput list-props 11 | grep "Device Enabled" | awk '{print $4}' )"

    if [ -z "$RESTORE" ]; then
        if [ "$STATE" == 0 ]; then
            STATE=1
            echo "Touchpad enabled"
        else
            STATE=0
            echo "Touchpad disabled"
        fi

        # Store the new state in STATE_FILE
        printf '%s' "$STATE" > "$STATE_FILE"
    fi

    # Toggle touchpad
    xinput set-prop "$id" "Device Enabled" "$STATE"
}

case "$1" in 
    "--restore" )
        RESTORE=1
esac

main