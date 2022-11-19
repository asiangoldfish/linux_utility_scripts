#!/usr/bin/bash

BUILD_DIR="./out/build/"     # Output directory
ROOT_DIR="."                 # The project's root directory
APP="$BUILD_DIR/App" # Executable file path
VERBOSE=false                # Whether to verbose output
BUILD_SYSTEM=""              # Project build system

# Detects what build system the project uses
function detect_system() {
    # use nullglob in case there are no matching files
    shopt -s nullglob

    # Gets all files in the directory
    local files=( "$( ls . )" )

    for file in $files; do
        case "$file" in
        "Makefile")
            BUILD_SYSTEM="Make"
            break
            ;;
        "CMakeLists.txt")
            BUILD_SYSTEM="CMake"
            break
            ;;
        esac
    done

    # Return 1 if no build system was found, else 0
    if [ -z "$BUILD_SYSTEM" ]; then return 1; else return 0; fi
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
    "CMake") cmake -S "$ROOT_DIR" -B "$BUILD_DIR" && make -C "$BUILD_DIR"
    esac
    return 0
}

# Run the program
function execute_app {
    "$APP"
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
    -v, --verbose           verbose output
"
}

# Help page when running without arguments
if [ "$#" == 0 ]; then
    usage
    exit 0
fi

if ! detect_system; then
    echo "$0: Could not detect build system in this project"
    exit 0
fi

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
        build 1>/dev/null && execute_app
        break
        ;;
    "-r" | "--rebuild") # Delete build files and build project
        clean && build
        break
        ;;
    "-v" | "--verbose") # Verbose output
        VERBOSE=true
        ;;
    *) # Help page on invalid argument
        printf "%s: Invalid argument \'%s\'\n" "$0" "$arg"
        break
        ;;
    esac
done
