#!/usr/bin/bash

NAME="$0"                   # This script's name

BUILD_DIR="./out/build/" # Output directory
ROOT_DIR="."             # The project's root directory
APP="$BUILD_DIR/App"     # Executable file path
BUILD_SYSTEM=""          # Project build system
CACHE=".cache/simple_build" # Cache directory

VERBOSE=0      # Whether to verbose output
EXTRAVERBOSE=0 # Whether to extra verbose output

OPTIONS="./simple_build.txt" # The file to fetch simple_build options from
COMMENTS_PREFIX="#"       # Comments prefix in the OPTIONS file

# Detects what build system the project uses
function initiate() {
    # Detect build system
    if [ -f "Makefile" ] || [ -f "makefile" ]; then
        BUILD_SYSTEM="Make"
    elif [ -f "CMakeLists.txt" ]; then
        BUILD_SYSTEM="CMake"
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
        local cmake_options; cmake_options=$(parse_cmake_options)
        cmake "$cmake_options" -S "$ROOT_DIR" -B "$BUILD_DIR" &&
            make -C "$BUILD_DIR"
        ;;
    esac
    return 0
}

# Run the program
function execute_app() {
    "$APP"
}

# Parses CMake options
function parse_cmake_options() {
    local tmpFile="$CACHE/temporary_options.txt"

    # Check if the OPTIONS file exist
    if [ ! -f "$OPTIONS" ]; then
        printf ""
        return 0
    fi

    # Create cache directory
    if [ ! -d "$CACHE" ]; then mkdir -p "$CACHE"; fi

    # Copy the OPTIONS file to temporary file without comments
    sed '/^\#/d' "$OPTIONS" > "$tmpFile" || return 1

    # Concatenate all lines into one string
    local output
    output="$(cat < "$tmpFile" | paste -s -d' ')"

    # Print lines without trailing whitespaces
    printf '%s' "$output" | xargs

    return 0
}

parse_cmake_options
exit

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
