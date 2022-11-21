#!/usr/bin/bash

NAME="$0"                   # This script's name

BUILD_DIR="./out/build/" # Output directory
ROOT_DIR="."             # The project's root directory
APP="$BUILD_DIR/App"     # Executable file path
BUILD_SYSTEM=""          # Project build system
CACHE="$HOME/.cache/simple_build" # Cache directory

VERBOSE=0      # Whether to verbose output
EXTRAVERBOSE=0 # Whether to extra verbose output

OPTIONS="./simple_build.conf" # The file to fetch simple_build options from

# Detects what build system the project uses
function initiate() {
    local makeTarget                # Make's target executable
    # Detect build system
    if [ -f "Makefile" ] || [ -f "makefile" ]; then
        BUILD_SYSTEM="Make"
    elif [ -f "CMakeLists.txt" ]; then
        BUILD_SYSTEM="CMake"
    fi

    # If the build system is Make, parse the options file for cmake
    if [ "$BUILD_SYSTEM" == "Make" ]; then
        parse_make_options
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
        local cmake_options=$(parse_cmake_options)
        cmake "$cmake_options" -S "$ROOT_DIR" -B "$BUILD_DIR" &&
            make -C "$BUILD_DIR"
        ;;
    esac
    return 0
}

# Run the program
function execute_app() {
    if [ -z "$APP" ]; then
        echo "$NAME: Could not find executable"
        return 1
    else
        return 0
    fi
}

# Parses CMake options
function parse_cmake_options() {
    local tmpFile="$CACHE/temporary_options.txt"

    # Check if the OPTIONS file exist
    if [ ! -f "$OPTIONS" ]; then
        printf ""q
        return 0
    fi

    # Create cache directory
    if [ ! -d "$CACHE" ]; then mkdir -p "$CACHE"; fi

    # Copy the OPTIONS file to temporary file without comments
    # Change the sed expression to change the comment prefix
    sed '/^\#/d' "$OPTIONS" > "$tmpFile" || return 1

    # Concatenate all lines into one string
    local output
    output="$(cat < "$tmpFile" | paste -s -d' ')"

    # Print lines without trailing whitespaces
    printf '%s' "$output" | xargs

    return 0
}

# Parse Make options
function parse_make_options() {
    # Source the options file
    source "$OPTIONS"
    APP="$TARGET"
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
