
BUILD_FILE="angular.json"     # Special configuration file in project dir

# The build system's invocation command
BUILD_COMMAND="ng build"

# Command to clear files, like build files
CLEAN_COMMAND="empty"

# Parses CMake options
function parse_options() {
    :
}

function empty() {
    echo "Nothing to clean"
}
