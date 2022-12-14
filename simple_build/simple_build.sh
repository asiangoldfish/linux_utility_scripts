#!/usr/bin/bash

################################################################################
#                            This script's base details                        #
################################################################################
NAME="$( basename "$0" )"                                   # This script's name
LOCAL_SCRIPT="./simple_build.sh"                            # This script's name in a project
SCRIPT_PATH=""                                              # Script parent dir
CONF_TEMPLATE=''                                            # simple_build.conf template

# If this script exists in the project directory, then use that instead.
# Skip if that script and the current one are the same
if [ -f "$LOCAL_SCRIPT" ] && [ ! "$(find $LOCAL_SCRIPT)" == "$NAME"  ]; then
    if source "$LOCAL_SCRIPT"; then 
        exit 0 
    else
        echo "$NAME: Could not source the local script"
        exit 1
    fi 
fi
################################################################################

################################################################################
#                            Build details                                     #
################################################################################
BUILD_DIR="./out/build/"                # Default output directory
ROOT_DIR="."                            # The project's root directory
TARGET_EXECUTABLE=""                    # Executable file path
BUILD_SYSTEM=""                         # Project build system
CACHE="$HOME/.cache/simple_build"       # Cache directory

BUILD_FILE=""                           # Special config file for the build
                                        # system, like CMakeLists.txt. This
                                        # is set by the build system's dirname
                                        # in this script's SCRIPT_PATH

INI_PARSER=""                           # Ini parser script

OPTIONS="simple_build.conf"             # Options to configure script behaviour
################################################################################

####
# This function is the first one executed in this program
####
function main() {
    # Parses command-line arguments and executes functions accordingly
    parseArgsAndExecute "$@"
}

# Build project
function build() {
    # Determine verbosity
    local VERBOSITY="&>/dev/null"
    for arg in "$@"; do
        case "$arg" in
        "-v"  | "--verbose"      ) VERBOSITY="1>/dev/null"; break;;
        "-vv" | "--extra-verbose") VERBOSITY=""; break;;
        esac
    done

    # Output error if build command was not found
    if [ -z "$BUILD_COMMAND" ]; then
     printf "%s: Missing build command. Ensure that it's passed using " "$NAME"
     printf "the BUILD_COMMAND variable in file \'parse_conf.sh\'\n">/dev/stderr
        return 1
    else
        eval "$BUILD_COMMAND" "$VERBOSITY"
        return "$?"
    fi
}

# Clean build directory
function clean() {
    # Output error if clean command is not found
    if [ -z "$CLEAN_COMMAND" ]; then
        echo "$NAME: Clean command not found" > /dev/stderr
        return 1
    else
        eval "$CLEAN_COMMAND"
        return "$?"
    fi
}

function detectBuildSystem() {
       # Detect build system by iterating all directories in the SCRIPT_PATH,
    # excluding directories from EXCLUDE_DIRS. Then, source parse_conf.sh
    # accordingly
    local all_dirs          # All directories within the script's path
    local dir               # Iterated directory
    local tmp_build_file    # Found BUILD_FILE in iterated directory
    local tmp_parse_conf    # Iterated parse_conf.sh

    IFS=' ' read -ra all_dirs <<< "$( echo "$( dirname "$SCRIPT_PATH" )"/* )"

    for dir in "${all_dirs[@]}"; do
        # Skip iteration if the selected item is not a directory
        if [ ! -d "$dir" ]; then continue; fi

        tmp_parse_conf="$dir/parse_conf.sh"
        
        # Go to next iteration if the parse_conf.sh file doesn't exist
        if [ -f "$tmp_parse_conf" ]; then
            tmp_build_file="$( source "$tmp_parse_conf" && echo "$BUILD_FILE" )"
        else
            continue
        fi

        # Detect build system in project
        if [ -z "$tmp_build_file" ]; then
            # Print error message if the BUILD_FILE variable is empty
            # Example: CMakeLists.txt or Makefile
            echo "$NAME: Missing $tmp_build_file" > /dev/stderr
            return 1
        elif [ ! -f "$tmp_build_file" ]; then
            # Go to next iteration if the build configuration is not found
            continue
        elif [ -f "$tmp_build_file" ]; then
            source "$tmp_parse_conf"
            parse_options
        
            break
        else
            echo "$NAME: Error at line no. $LINENO:" 
echo -e "\tUnexpected behavioural in the if-statements. This shouldn't happen"
        fi
    done
}

# Run the program
function execute_app() {
    # Determine verbosity. This is passed to the build function
    local VERBOSITY
    for arg in "$@"; do
        if [ "$arg" == "-v" ] || \
        [ "$arg" == "-vv" ] || \
        [ "$arg" == "--verbose" ] || \
        [ "$arg" == "--extra-verbose" ]; then
            VERBOSITY="$arg"
        fi
    done

    # If run command was detected from simple_build.conf, then execute that command
    if [ -n "$RUN_COMMAND" ]; then
        eval "$RUN_COMMAND"

    # else, build project and run executable file
    else
        # If the executable doesn't exist, then attempt to build the project. This
        # assumes that a build system was found
        if [ ! -f "$TARGET_EXECUTABLE" ] && [ -n "$BUILD_SYSTEM" ]; then
            build "$@" || return "$?"
            "$TARGET_EXECUTABLE"
        else
            eval "$TARGET_EXECUTABLE"
        fi
    fi
    
    return "$?"
}

####
# Generate a simple_build.conf template to local project directory
#
# The generated simple_build.conf is copied from this script directory's
# sb_conf.template. The user is also offered to review it using the set $EDITOR
# environment variable.
####
function generateOptionsFile() {
    local editorChoice      # yes or no
    
    # Set the template absolute system filepath
    setConfTemplate

    # Generate simple_build.conf if none is found in the local project directory
    if [ ! -f "./simple_build.conf" ]; then
        echo "Generating simple_build.conf..."
        cp "$CONF_TEMPLATE" "$PWD/simple_build.conf"

        # Allow editing the file using the $EDITOR environment variable if set
        if [ -z "$EDITOR" ]; then
            # EDITOR variable is empty or not set
            echo -e "Manually editing simple_build.conf is advised"
            return 0
        else
            # Prompt user to review the simple_build.conf with EDITOR
            read -p "Review using $( basename "$EDITOR" )? [Y/n] " editorChoice
        fi

        if [ -z "$editorChoice" ] || [[ "$editorChoice" == [Yy] ]]; then
            "$EDITOR" "./simple_build.conf"
        else
            echo "Manually editing simple_build.conf is advised"
            return 1
        fi
    fi
    
    return 0
}

####
# Initiates important processes for this script
#
# 1. Figures out wether this script is a working symlink and sets its path
#    accordingly
# 2. Checks whether the ini parser exists and returns an error if not
# 3. Checks whether the target project includes an options file. See OPTIONS
#    for its filepath
# 4. Detects the project's build system
####
function initiate() {
    # Sets this script's path
    setScriptPath

    # Checks that the ini_parser script exists. This is used to parse variables
    # from the OPTIONS file.
    INI_PARSER="$( dirname $SCRIPT_PATH )/lib/ini_parser/ini_parser.py" # Ini parser script
    if [ ! -f "$INI_PARSER" ]; then
        echo "$NAME: Could not find the ini parser"
        return 1
    fi

    # Generate an options file if it doesn't already exist
    if [ ! -f "$OPTIONS" ]; then
        generateOptionsFile
        return 1
    fi

    detectBuildSystem || return 1

    # Return 1 if no build system was found, else 0
    if [ -z "$BUILD_FILE" ]; then 
        echo "$NAME: Could not detect build system"
        return 1
    fi

    # Source local project's simple_build.conf
    if [ -f "./simple_build.conf" ]; then
        source "./simple_build.conf"
    fi

    return 0
}

####
# Helper function that finds the absolute file path of the
# simple_build.conf template
####
function setConfTemplate() {
    CONF_TEMPLATE="$( dirname $SCRIPT_PATH )/sb_conf.template"
}

####
# Sets this script's file path. If it's a symlink, then gets the original path
####
function setScriptPath() {
    local isSymlink     # Whether this script is a symlink

    if [ -z "$( ls -l "$0" | awk '{print $11}' )" ]; then
        isSymlink=false
    else
        isSymlink=true
    fi

    if [ "$isSymlink" == false ]; then
        SCRIPT_PATH="$0"
    else
        SCRIPT_PATH="$( ls -l "$0" | awk '{print $11}' )"
    fi
}

# Help page
function usage() {
    echo -n "Usage: $NAME [OPTION] ...

$NAME, a management script for more efficient build process during development

Options:
    -b, --build             build project
    -c, --clean             remove build files
    -e, --execute           run the application
    -h, --help              this page
    -r, --rebuild           rebuild project
    -v, --verbose           only print errors
    -vv, --extra-verbose    print outputs and errors
"
}

function parseArgsAndExecute() {
    # Help page when running without arguments
    if [ "$#" == 0 ]; then
        usage
        exit 0
    fi

    # Loop arguments
    for arg in "$@"; do
        case "$arg" in
        "-b" | "--build")
            ! initiate && return 1
            build "$@"
            break;;
        "-c" | "--clean") 
            clean "$@" 
            break;;
        "-e" | "--execute") 
            ! initiate && return 1
            execute_app "$@"
            break;;
        "-h" | "--help")
            usage
            break;;
        "-r" | "--rebuild") 
            ! initiate && return 1
            clean && build
            break;;
        * )
            echo "$NAME: Unrecognized command $arg. Use --help for commands"
            break;;
        esac
    done
}

################################################################################
main "$@"
################################################################################