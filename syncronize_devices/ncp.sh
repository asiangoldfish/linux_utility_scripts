#!/usr/bin/bash

# Assign your ip addresses underneath
DEVICE1=''                                  # DEVICE1 ip address
DEVICE2=''                                  # DEVICE2 ip address

THIS=''                                     # This computer's ip address
TARGET=''                                   # Target computer's ip address

# Assign your username here
USER=''                                     # Host username
NAME="ncp"                                  # Script name
PING_COUNT=1                                # How many times to ping the target

# Assign directories to sync here. Note that you need read/write permissions
DIRS=(                                      # Directories to sync
    "Documents"
    "Downloads"
)

####
# Updates self and target ip
####
function self_ip() {
    # Set this computer's IP address
    IPS='\n' read -ra THIS <<< "$(ip route | awk '{print $9}')" 
    case "${THIS[0]}" in
        "$DEVICE2" ) TARGET="$DEVICE1" ;;
        "$DEVICE1" ) TARGET="$DEVICE2" ;;
    esac
    return 0
}

####
# Pings target to check whether it exists
####
function pingTarget() {
    # Pings the target
    printf "Finding target address %s...\n" "$TARGET"
    if ! ping "$TARGET" -c "$PING_COUNT" 1> /dev/null; then
        printf "Could not find target address %s\n" "$TARGET"
        return 1
    else
        return 0
    fi
}
`
function usage() {
    echo -n "Usage: $NAME [OPTION] ...

Utility tool for managing the Panda Database.

Options:
    -d, --download          download files from target
    -h, --help              this page
    -u, --upload            upload files to target
"
}

# Check password correctness

if [ -z "$1" ]; then
    usage
    exit 0
fi

self_ip

case "$1" in
"-d" | "--download")
    if pingTarget; then
        echo "Downloading..."
        for dir in "${DIRS[@]}"; do
            rsync -auv "$USER@$TARGET:/home/$USER/$dir" "$HOME" # Download content from remote to local machine via SSH
        done
    else
        echo "Could not reach target"
        exit 1
    fi
    ;;
"-u" | "--upload")
    if pingTarget; then
        echo "Uploading..."
        for dir in "${DIRS[@]}"; do
            rsync -auv "$HOME/$dir" "$USER@$TARGET:/home/$USER" # Upload content from local to remote machine via SSH
        done
    else
        echo "Could not reach target"
        exit 1
    fi
    ;;
*)
    usage
esac
