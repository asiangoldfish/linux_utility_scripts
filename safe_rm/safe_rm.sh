#!/usr/bin/bash

################################################################################
## LICENSE:                                                                   ##
## The MIT License (MIT)                                                      ##
## Copyright © 2022 Khai Duong                                                ##
##                                                                            ##
## Permission is hereby granted, free of charge, to any person obtaining a    ##
## copy of this software and associated documentation files (the “Software”), ##
## to deal in the Software without restriction, including without limitation  ##
## the rights to use, copy, modify, merge, publish, distribute, sublicense,   ##
## and/or sell copies of the Software, and to permit persons to whom the      ##
## Software is furnished to do so, subject to the following conditions:       ##
##                                                                            ##
## The above copyright notice and this permission notice shall be included in ##
## all copies or substantial portions of the Software.                        ##
##                                                                            ##
## THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR ##
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,   ##
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    ##
## THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER ##
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING    ##
## FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER        ##
## DEALINGS IN THE SOFTWARE.                                                  ##
################################################################################

################################################################################
## DISCLAIMER:                                                                ##
## Please review the script before using it for yourself.                     ##
################################################################################

################################################################################
## Add this script to PATH before using it.                                   ##
## To temporarily adding it to PATH, use the following command:               ##
##    PATH="PATH:[SCRIPT_PATH]"                                               ##
## Replace '[SCRIPT_PATH]' with the script's actual file path                 ##
## To add it to PATH permanently, add the same line in your .bashrc           ##
## configuration file.                                                        ##
################################################################################

PAPERBIN="$HOME/Paperbin"                          # Directory with all trashed files
PROJECT_NAME="safe_rm"                             # This project's name
RECORD="$XDG_CONFIG_HOME/$PROJECT_NAME/record.txt" # Record of all current files in paperbin

####
# Main program
####
function main() {
    local input_string="$*"                   # Fetches all files as string
    local IFS                                 # String delimiter
    IFS=' ' read -ra FILES <<<"$input_string" # Converts to array
    local file                                # Iterated file in FILES
    local ls_out                              # ls output
    local unrecognized_files=()               # Unrecognized files in system
    local files_total
    local status_movetobin=0 # Status code after moving to paperbin
    local path_hash          # A file path's md5 checksum
    local content_hash       # A file content's md5 checksum
    local new_filename       # Combined hashes

    # Iterate all files to delete
    for file in "${FILES[@]}"; do

        # Move directory to paperbin
        if [ -d "$file" ]; then
            # Figure out whether files exist in the directory
            ls_out="$(ls -l "$file" | wc -l)" # ls output

            # TODO - Implement checksum

            # Check for '-r' flag before moving non-empty directories
            if [[ "$ls_out" -gt 1 ]] && validateFlags "-r"; then
                # Hash the file path and file content, then merge into the file's new name
                moveToBin "$file" "$PAPERBIN"
                status_movetobin="$?"

                # Only track the file if the transfer was successful
                if [ "$status_movetobin" == 0 ]; then
                    appendToFile "$file" "$RECORD"
                fi

            # Move empty directories
            elif [ "${files_total[1]}" == 0 ]; then
                moveToBin "$file" "$PAPERBIN"
                appendToFile "$file" "$RECORD"
            fi

        # Move files
        elif [ -f "$file" ]; then
            moveToBin "$file" "$PAPERBIN"
            appendToFile "$file" "$RECORD"
        else
            # Detect unrecognized files
            unrecognized_files+=("$file")
        fi
    done

    # Print all name of unrecognized files
    if [[ "${#unrecognized_files}" -gt 0 ]]; then
        for file in "${unrecognized_files[@]}"; do
            printf "del: cannot remove \'%s\': No such file or directory\n" "$file"
        done
        return 1
    fi

    return 0
}

####
# Append file content to another file
####
function appendToFile() {
    SOURCE="$1"
    TARGET="$2"

    echo "$(readlink -f "$SOURCE") $SOURCE" >>"$TARGET"

    return 0
}

####
# Check if the paperbin exists
####
function doesBinExist() {
    if [ -d "$PAPERBIN" ]; then return 0; fi

    printf "There is no paperbin in your home directory. Aborting...\n"
    return 1

}

####
# Empty paperbin
####
function emptyBin() {
    # Check if paperbin exists
    if ! doesBinExist; then exit 1; fi

    local PROMPT # User reply from prompt
    local ls_out # Amount of items in the paperbin

    # Do nothing if the paperbin is empty
    ls_out="$(ls -l "$PAPERBIN" | wc -l)" # ls output

    if [ "$ls_out" == 1 ]; then
        printf "Nothing to empty\n"
        return 0
    fi

    # Prompt for emptying the paperbin
    printf "Are you sure you want to empty the paperbin? [y/N] "
    read PROMPT

    # Empty paperbin
    if [ "$PROMPT" = 'y' ] || [ "$PROMPT" == 'Y' ]; then
        rm -rf "${PAPERBIN:?}"/* "$RECORD"
        printf "The paperbin is empty\n"
    fi

    return 0
}

####
# Initialize important systems
####
function initialize() {
    # $HOME
    if [ -z "$HOME" ]; then
        printf "\$HOME is not set\n"
        return 1
    fi

    # $XDG_CONFIG_HOME
    if [ -z "$XDG_CONFIG_HOME" ]; then
        XDG_CONFIG_HOME="$HOME/.config"
    fi

    # Does RECORD exist
    if [ ! -f "$RECORD" ]; then
        mkdir -p "$XDG_CONFIG_HOME/$PROJECT_NAME"
        touch "$RECORD"
    fi

    # readlink - Utility from the GNU coreutils project
    command -v readlink &>/dev/null || return 1

    return 0
}

####
# List all items in the paperbin
####
function list() {
    if ! doesBinExist; then exit 1; fi

    cat "$RECORD"
}

####
# Create the paperbin
####
function mkdirBin() {
    # Create paperbin
    if [ ! -d "$PAPERBIN" ]; then
        mkdir "$PAPERBIN"
    fi
}

####
# Moves a given file to the paperbin
####
function moveToBin() {
    local FILE="$1" # File to move to paperbin
    local PROMPT

    # Check if an equally named file exists in paperbin and prompt to delete
    if ! ls "$PAPERBIN/$FILE" &>/dev/null; then
        mv "$FILE" "$PAPERBIN"
        return 0
    else
        # Prompt for replacement
        printf "Directory \'%s\' already exists in the paperbin. Replace? [Y/n] " \
            "$FILE"

        # Prompt for deletion
        read -r PROMPT
        if [ -z "$PROMPT" ] || [[ "$PROMPT" =~ ['Yy'] ]] && [ "${#PROMPT}" -le 1 ]; then
            rm -rf "${PAPERBIN:?}/$FILE"
            mv "$FILE" "$PAPERBIN"
        fi
    fi

    return 0
}

####
# Help page
####
function usage() {
    cat <<EOF
Usage: del [OPTIONS] files...

Moves files to the paperbin for review instead of permanently deleting them.

OPTIONS:
    -e, --empty-bin         empty the paperbin
    -h, --help              this page
    -l, --list              list all items in the paperbin
    -r, --recursive         moves non-empty directory to paperbin
EOF
}

####
# Parse command-line arguments
#
# Executes the main function if user options and arguments are valid
####
function parseCli() {
    if [ -z "$1" ]; then
        usage
        exit
    fi

    for arg in "$@"; do
        case "$arg" in
        "-e" | "--empty-bin")
            emptyBin
            return 0
            ;;
        "-h" | "--help")
            usage
            return 0
            ;;
        "-l" | "--list")
            list
            return 0
            ;;
        "-r" | "--recursively")
            RECURSIVE=true
            ;;
        *)
            # Output error if the invalid flag starts with '--'
            if [ "${1:0:2}" == '--' ]; then
                printf "del: unrecognized option %s\n" "$1"
                printf "Try \'del --help\' for more information.\n"
                exit 1
            # Output error if the invalid flag starts with '-'
            elif [ "${1:0:1}" == '-' ]; then
                printf "del: unrecognized option %s\n" "${1:0:2}"
                printf "Try \'del --help\' for more information.\n"
                exit 1

            fi

            # Assumes all other arguments to be file names
            files+=("$arg")
            ;;
        esac
        shift
    done

    main "${files[@]}"
}

####
# Validate flags before continuing the command
####
function validateFlags() {
    for flag in "$@"; do
        case "$flag" in
        '-r')
            # '-r' flag must be present before deleting the file
            if [ -z "$RECURSIVE" ]; then
                printf "del: non-empty directories requires option \'-r\'\n"
                return 1
            fi
            ;;
        esac
        shift
    done

    return 0
}

# Initialize the application
if ! initialize; then exit 1; fi

# Parse command-line arguments
parseCli "$@"
