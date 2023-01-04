#!/usr/bin/bash

NAME="$( basename "$0" )"       # This script's name
DIRPATH=""                      # This script's directory path

KEEP_WORKSPACES=true
TRACKER_DIR="$HOME/.i3/i3-resurrect"
TRACKER="$TRACKER_DIR/../tracker"

DEPS=(
    "jq"
)

#######################################
# Get this script's actual directory path
#
# Globals:
#   DIRPATH - This script's original directory path#
# Arguments:
#   None
#######################################
function set_dirpath() {
    # If script is symlinked, this gets the original filepath
    local symlink="$( ls -l "$0" | awk '{print $11}' )"

    # If symlinked, then we set dirpath as the original file's directory path
    if [ -n "$symlink"  ]; then
        DIRPATH="$( dirname "$symlink" )"
    else
        DIRPATH="$( dirname "$0" )"
    fi
}

#######################################
# Check that all dependencies are met#
# Arguments:
#   None
#######################################
function initialize() {
    local status

    for dep in "${DEPS[@]}"; do
        status="$( command -v "$dep" &> /dev/null; echo "$?" )"
        
        if [ "$status" != 0 ]; then
            echo "Missing dependency: $dep";
            return "$status";
        fi
    done

    # Set correct directory path of this script
    set_dirpath

    # ANSI colors
    source "$DIRPATH/lib/colors.conf"

    # Source command-functions
    source "$DIRPATH/lib/list.sh"
    source "$DIRPATH/lib/restore.sh"
    source "$DIRPATH/lib/save.sh"
}

#######################################
# Parse arguments from the command-line
#
# Arguments:
#   None
#######################################
function parse_cli() {
    local arg

    # Runs help message if no arguments were found
    if [[ $# -eq 0 ]]; then usage; return 1; fi

    # Checks for flags and runs accordingly
    for arg in "$@"; do
        case $arg in
            # Usage
            "h" | "help" | "--h" | "--help" ) usage; break ;;

            # List workspaces or profiles
            "list" ) initialize && list "$2"; return "$?" ;;

            # Restore
            "restore" ) initialize && restore "$2"; return "$?" ;;
            "restore-all" ) initialize && restore_all; return "$?" ;;
            
            # Save
            "save" ) initialize && save "$2"; return "$?" ;;
            "save-by-profile" )
                initialize && save_by_profile "$2" "$3";
                return "$?"
                ;;
            "save-all" ) initialize && save_all; return "$?" ;;
            "save-all-by-profile" )
                initialize && save_all_by_profile "$2"
                return "$?"
                ;;

            * ) usage ;;
        esac
        shift
    done

    return 0
}

#######################################
# Manage the tracker file that keeps record of saved workspaces
#   
# Arguments:
#   --create:   Create new tracker if it doesn't already exist
#   --recreate: Recreate tracker regardless if it already exists
#   --delete:   Delete tracker
#
# Errors:
#   Hard exits the program if an error occurs with stack trace
#######################################
function manage_tracker() {
    local caller_lineno="$( caller | awk '{print $1}' )"
    local caller_file="$( caller | awk '{print $2}' )"
    local error_msg=

    case "$1" in
        
        # Create new tracker
        "--create" )
            if [ ! -f "$TRACKER" ]; then
                mkdir -p "$TRACKER_DIR"         # Directory to store workspaces
                touch "$TRACKER"                # Record file of saved workspaces
            fi
            ;;

        # Recreate tracker
        "--recreate" )
            if [ ! -f "$TRACKER" ]; then
                mkdir -p "$HOME"/.i3/i3-resurrect
                touch "$TRACKER"
            else
                rm "$TRACKER" && touch "$TRACKER"
            fi
            ;;

        # Delete tracker
        "--delete" )
            if [ -f "$TRACKER" ]; then
                rm "$TRACKER"
            fi
            ;;
        
        # Invalid arg
        * )
            printf "${Red}Error at %s in %s:${NC}\nCommand not found\n" \
                "$caller_lineno" "$caller_file" > /dev/stderr
            exit 1
            ;;
    esac
}

#######################################
# Help page for this script
#
# Arguments:
#   None
# 
# Outputs:
#   Commands available for this script  
#######################################
function usage() {
    echo -n "Usage: $NAME [OPTION]

Wrapper for the i3-resurrect project at:
https://github.com/JonnyHaystack/i3-resurrect

Options:
    h, help                 this page
    ls                      list all saved workspaces
        --profile           list all profiles
        --profile=NAME      list saved workspaces for a named profile

    save [index]            save a workspace (default: current)
    save-all                save all workspaces
    save-by-profile [name]  save a workspace as profile with the given name
        --all               save all workspaces as profile

    remove [index]          remove a workspace by a given index
    remove-all              remove all saved workspaces
        --profile           remove all saved profiles

    restore-all             restore all workspaces
"
}

parse_cli "$@"


