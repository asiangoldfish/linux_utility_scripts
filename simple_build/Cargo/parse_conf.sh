
BUILD_FILE="Cargo.toml"     # Special configuration file in project dir

# The build system's invocation command
BUILD_COMMAND="cargo run"

# Command to clear files, like build files
CLEAN_COMMAND="empty"

# Parses CMake options
function parse_options() {
    :
}

function empty() {
    echo "Nothing to clean"
}
