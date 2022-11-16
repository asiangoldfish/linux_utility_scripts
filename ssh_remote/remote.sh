#!/usr/bin/bash

function server() {
    local user
    local address

    if [ -z "$1" ]; then
        user=                   # Default user to connect to
    else
        user="$1"
    fi
        address=""              # Device ip address or hostname

    ssh "$user"@"$address"

    return 0
}