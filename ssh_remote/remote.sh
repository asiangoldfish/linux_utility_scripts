#!/usr/bin/env bash

# List of valid targets
NAMES=(
    "ubuntu"
)
TARGETS=(
    "127.0.0.1"
)

function usage() {
    echo "Usage: remote.sh [TARGET]

Enter a valid target to connect to it.
Available targets:"

    local ip
    for ip in "$NAMES"; do
        printf "\t$ip\n"
    done

    return 0
}

# No commands were passed. Print help page
if [ -z "$1" ]; then
    usage
    exit 1
fi

let index=0
for ip in "${NAMES[@]}"; do
    if [ "$1" == "$ip" ]; then
        # IP was found
        ssh "${USERS[$index]}@${TARGETS[$index]}"
        exit "$?"
    fi

    let index++
done

echo "Target $1 not found"

