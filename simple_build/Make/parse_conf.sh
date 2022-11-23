
BUILD_FILE="Makefile"     # Special configuration file in project dir
BUILD_COMMAND="make"          # The build system's invocation command

# Parse Make options
function parse_options() {
    # Source the options file
    source "$OPTIONS"
    TARGET_EXECUTABLE="$TARGET"
}