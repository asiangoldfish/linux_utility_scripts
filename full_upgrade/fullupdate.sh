#!/usr/bin/bash

# One stop shop to fully upgrade the entire system

NAME="$(basename "$0")"

# Edit this array to include dependencies that this script relies on
DEPS=(
    'lsb_release'
)

# Commands to fully upgrade systems
ArchLinux="yes | yay -Syyu"
Debian="sudo apt update && sudo apt upgrade"
ManjaroLinux="yes | yay -Syyu"


function absolutePath() {
    printf "%s\n" "$0"
}

####
# Detect system name
#
# Uses the lsb_release command to detect the systen name
####
function detectSystem() {
    printf "%s" "$( lsb_release -i | awk '{print $3}' )"
}

function fullUpgrade() {
    # Detect system
    local systemName="$(detectSystem)"
    local exitCode=0
    
    # Attempt to update system based on the system name
    if [ -z "$systemName" ]; then

        return 1
    fi

    # Edit this case-block to add new commands to execute
    case "$systemName" in 
        'ArchLinux') eval "$ArchLinux";;
        'Debian') eval "$Debian";;
        'ManjaroLinux') eval "$ManjaroLinux";;
        *)
            printf "%s: System %s not recognized. Edit this script to include it" \
        "$NAME" "$systemName"
        exitCode=1
    esac

    return "$exitCode"
}

function main() {
    # Help page when running without arguments
    #if [ "$#" == 0 ]; then
    #    fullUpgrade
    #    return 1
    #fi
    
    # Parse command-line arguments or return exit code
    parseArgs "$@" || return "$?"

    # Detect missing dependencies
    verifyDeps

    # Fully upgrade the system
    fullUpgrade
}

function parseArgs() {
    # Loop arguments
    for arg in "$@"; do
        case "$arg" in
        '-h' | '--help') usage; break;;
        '-p' | '--p') absolutePath; break;;
        *) # Help page on invalid argument
            printf "%s: Invalid argument \'%s\'\n" "$NAME" "$arg"
            return 1
            ;;
        esac
    done
}

# Help page
function usage() {
    echo -n "Usage: $NAME [OPTION] ...

Fully upgrade the system. Edit this script to customize the upgrade process.

Options:
    -h, --help              this page
    -p, --path              this script's absolute file path
"
}

function verifyDeps() {
    local dep           # Currently iterated dependency
    local missingDeps   # List of found missing dependencies

    for dep in "${DEPS[@]}"; do
        command -v "$dep" &> /dev/null || missingDeps+=( "$dep" )
    done
    
    if [ "${#missingDeps[@]}" -gt 0 ]; then
        printf "Missing dependencies:\n"

        for dep in "${missingDeps[@]}"; do
            printf "\t%s\n" "$dep"
        done
    fi
}

main "$@"