#!/usr/bin/bash

################################################################################
#                            This script's base details                        #
################################################################################
NAME="$( basename "$0" )"                                   # This script's name
LOCAL_SCRIPT="./simple_build.sh"                            # This script's name in a project
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # Script parent dir

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
BUILD_DIR="./out/build/"                # Output directory
ROOT_DIR="."                            # The project's root directory
TARGET_EXECUTABLE="$BUILD_DIR/App"      # Executable file path
BUILD_SYSTEM=""                         # Project build system
CACHE="$HOME/.cache/simple_build"       # Cache directory

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
    # Checks if this script is a working symlink
    if [[ -L "$SCRIPT_PATH/$NAME" ]] && [ -e "$SCRIPT_PATH/$NAME" ]; then
        # If this script indeed is a symlink, then find the real path
        SCRIPT_PATH="$( readlink "$( command -v configure.sh )" )"
        SCRIPT_PATH="$( dirname "$SCRIPT_PATH" )"
    else
        echo "$NAME: This script might be a link, but it doesn't exist"
        return 1
    fi

    # Checks that the ini_parser script exists
    # INI_PARSER="$SCRIPT_PATH/ini_parser/ini_parser.py" # Ini parser script
    INI_PARSER="$HOME/Documents/UTILITIES/ini_parser/ini_parser.py" # Ini parser script

    if [ ! -f "$INI_PARSER" ]; then
        echo "$NAME: Could not find the ini parser"
        return 1
    fi

    # Checks that the options file exists
    if [ ! -f "$OPTIONS" ]; then
        echo -e "$NAME: Could not find \'$OPTIONS\'"
        return 1
    fi

    # Detect build system and source parse_conf.sh accordingly
    if [ -f "Makefile" ] || [ -f "makefile" ]; then
        BUILD_SYSTEM="Make"
        source "$SCRIPT_PATH/$BUILD_SYSTEM/parse_conf.sh"
    elif [ -f "CMakeLists.txt" ]; then
        BUILD_SYSTEM="CMake"
        source "$SCRIPT_PATH/$BUILD_SYSTEM/parse_conf.sh"
        parse_cmake_options
    fi

    # Return 1 if no build system was found, else 0
    if [ -z "$BUILD_SYSTEM" ]; then 
        echo "$NAME: Could not detect build system"
        return 1
    fi

    return 0
}

# Clean build directory
function clean() {
    case "$BUILD_SYSTEM" in
    "Make") make clean ;;
    "CMake") rm -rf "$BUILD_DIR" ;;
    esac
}

# Build project
function build() {
    case "$BUILD_SYSTEM" in
    "Make") make ;;
    "CMake")
        cmake "$cmake_options" -S "$ROOT_DIR" -B "$BUILD_DIR" &&
            make -C "$BUILD_DIR"
        ;;
    esac
    return 0
}

# Run the program
function execute_app() {
    if [ -z "$TARGET_EXECUTABLE" ]; then
        echo "$NAME: Could not find executable"
        return 1
    else
        "$TARGET_EXECUTABLE"
        return 0
    fi
}

# Parse Make options
function parse_make_options() {
    # Source the options file
    source "$OPTIONS"
    TARGET_EXECUTABLE="$TARGET"
}

# Help page
function usage() {
    echo -n "Usage: $NAME [OPTION] ...

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
