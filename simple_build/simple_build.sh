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

VERBOSE=0                               # Whether to verbose output
EXTRAVERBOSE=0                          # Whether to extra verbose output

OPTIONS="simple_build.conf"             # Options to configure script behaviour
################################################################################

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

# Build project
function build() {
    # Output error if build command was not found
    if [ -z "$BUILD_COMMAND" ]; then
        echo "$NAME: Missing build command. Ensure that it's passed using the BUILD_COMMAND variable in file 'parse_conf.sh'" > /dev/stderr
        return 1
    else
        eval "$BUILD_COMMAND"
        return "$?"
    fi
}

# Run the program
function execute_app() {
    if [ -z "$TARGET_EXECUTABLE" ]; then
        echo "$NAME: Could not find executable"
        return 1
    else
        "$TARGET_EXECUTABLE"
        return "$?"
    fi
}

####
# Copy the simple_build.conf template to $PWD
function generateOptionsFile() {
    # Figure where the template is stored on the system
    setConfTemplate

    if [ ! -f "./simple_build.conf" ]; then
        echo "Generating simple_build.conf..."

        cp "$CONF_TEMPLATE" "$PWD/simple_build.conf"

        echo "simple_build.conf has been generated."
        echo "Please review it before executing this command again"
        return 1
    else
        return 0
    fi
}

####
# Helper function that finds the absolute file path of the
# simple_build.conf template
####
function setConfTemplate() {
    CONF_TEMPLATE="$SCRIPT_PATH/sb_conf.template"
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
    -v, --verbose           only output stderr
    -vv, --extra-verbose    output stdout and stderr
"
}

# Help page when running without arguments
if [ "$#" == 0 ]; then
    usage
    exit 0
fi

# Initiate this script's requirements
! initiate && exit 0

# Loop arguments
for arg in "$@"; do
    case "$arg" in
    "-b" | "--build") # Build project
        build
        break
        ;;
    "-c" | "--clean") # Clean build files
        clean
        break
        ;;
    "-e" | "--execute") # Run program
        if [[ "$EXTRAVERBOSE" -eq 1 ]]; then
            build
        elif [[ "$VERBOSE" -eq 1 ]]; then
            build 1>/dev/null
        else
            build &>/dev/null
        fi

        execute_app
        break
        ;;
    "-r" | "--rebuild") # Delete build files and build project
        clean && build
        break
        ;;
    "-v" | "--verbose") # Verbose output
        VERBOSE=1
        ;;
    "-vv" | "--extra-verbose") # Extra verbose output
        EXTRAVERBOSE=1
        ;;
    *) # Help page on invalid argument
        printf "%s: Invalid argument \'%s\'\n" "$0" "$arg"
        break
        ;;
    esac
done
