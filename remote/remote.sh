#!/usr/bin/bash

function client() {
    if [ -z "$1" ]; then
        bruker="ubuntu"
    else
        bruker="$1"
    fi
        addresse="10.212.169.194"

    ssh "$bruker"@"$addresse"

    return 0
}

function server() {
    if [ -z "$1" ]; then
        bruker="ubuntu"
    else
        bruker="$1"
    fi
    addresse="10.212.168.10";

    ssh "$bruker"@"$addresse"  

return
}

function private() {
    addresse="10.212.138.161"
    bruker="ubuntu"

    ssh "$bruker"@"$addresse"

    return 0
}
