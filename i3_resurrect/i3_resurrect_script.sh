#!/usr/bin/bash

NUM_OF_WORKSPACE=9
KEEP_WORKSPACES=true
TRACKER="$HOME/.i3/i3-resurrect/tracker"

DEPS=(
    "jq"
)

####
# Check that all dependencies are met
####
function initialize() {
    local status

    for dep in "${DEPS[@]}"; do
        status="$( command -v "$dep" &> /dev/null; echo "$?" )"
        
        if [ "$status" != 0 ]; then
            echo "Missing dependency: $dep";
            return "$status";
        fi
    done
}

####
# List workspaces or profiles
####
function list() {
    local arg="$1"
    
    # Parse arg
    case $arg in
        # If profiles, then list all saved profiles
        "profiles" ) i3-resurrect ls profiles; return "$?" ;;
        * )
            # We only accept no arg if profiles wasn't passed
            if [ -n "$arg" ]; then
                echo "list: unrecognized command $1"
            fi
            ;;
    esac

    i3-resurrect ls
    return "$?"
}

####
# Save workspaces
#
# Loops through workspaces 1 through 9 and saves each of them. It will skip
# all empty workspaces
####
function save_all() {
    initialize || return "$?"

    # Create file that tracks saved workspaces
    if [ ! -f "$TRACKER" ]; then
        mkdir -p "$HOME"/.i3/i3-resurrect
        touch "$TRACKER"
    else
        rm "$TRACKER" && touch "$TRACKER"
    fi

    # Fetch all used workspaces
    local cmd="$( i3-msg -t get_workspaces | jq '.[].num' )"

    local IFS=$'\n'

    # Iterate each used workspace
    echo "Saving workspaces:"
    echo "$cmd" | while read -r i; do
        i3-resurrect save -w "$i"
        echo -ne "$i\n" >> "$TRACKER"
        echo "Workspace $i [Complete]"
    done
}

function parse_cli() {
    local arg

    # Runs help message if no arguments were found
    if [[ $# -eq 0 ]]; then usage; return 1; fi

    # Checks for flags and runs accordingly
    for arg in "$@"; do
        case $arg in
            "h" | "help" | "--h" | "--help" ) usage; break ;;

            "list" ) list "$2"; return "$?" ;;
            
            "restore-all" ) restore_all; return "$?" ;;
            
            "save-all" ) save_all; return "$?" ;;

            * ) usage ;;
        esac
        shift
    done

    return 0
}

function usage() {
    echo -n "Usage: $NAME [OPTION] ...

Wrapper for the i3-resurrect project at:
https://github.com/JonnyHaystack/i3-resurrect

Options:
    h, help                 this page
    ls                      list all saved workspaces
        --profile           list all profiles
        --profile=NAME      list saved workspaces for a named profile

    save                    save a workspace (default: current)
        -w                  specify workspace index
    save-all                save all workspaces
    save-profile [NAME]     save a workspace as profile with the given name
        --all               save all workspaces as profile

    remove [INDEX]          remove a workspace by a given index
    remove-all              remove all saved workspaces
        --profile           remove all saved profiles

    restore-all             restore all workspaces
"
}

####
# Restore all workspaces
####
function restore_all() {
    # Immediately quit if there's nothing to restore
    if [ -d "$HOME/.i3/i3-resurrect" ]; then
        if [ ! "$(ls -A $HOME/.i3/i3-resurrect)" ]; then
            echo "Nothing to restore from"
            return 1
        fi
    
    else
        echo "Nothing to restore from"
        return 1
    fi

    initialize || return "$?"

    # Get all used workspaces
    local used_workspaces="$( cat $TRACKER )"
    local i
    local IFS=$'\n'
    
    # Restore workspaces
    echo "Restoring workspaces:"
    echo "$used_workspaces" | while read -r i; do
        i3-resurrect restore -w "$i"
        echo "Workspace $i [Complete]"
    done

    # Automatically go to workspace 1
    #i3-msg workspace number 1

    echo -e "\nClearing saved workspaces..."
    echo "$used_workspaces" | while read -r j; do
        i3-resurrect rm -w "$j"
    done
    
    rm "$TRACKER"
}

parse_cli "$@"


