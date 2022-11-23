
BUILD_DIR="./out/build/"                # Output directory

BUILD_FILE="CMakeLists.txt"     # Special configuration file in project dir

# The build system's invocation command
BUILD_COMMAND="cmake $cmake_options -S $ROOT_DIR -B $BUILD_DIR && \
            make -C $BUILD_DIR"

# Command to clear files, like build files
CLEAN_COMMAND="rm -rf $BUILD_DIR"

# Parses CMake options
function parse_options() {
    # Get the final executable path
    local tmpFile="$CACHE/temporary_options.txt"
    local iniSection="options"      # The section where all cmake options reside

    # Get the target executable path
    TARGET_EXECUTABLE="$(
        python "$INI_PARSER" \
            --file "$OPTIONS" \
            --value \
            --section "default" \
            --key "TARGET_eXECUTABLE"
    )"

    # Create cache directory
    if [ ! -d "$CACHE" ]; then mkdir -p "$CACHE"; fi

    # All cmake options under the options section
    local build_options="$(
        python "$INI_PARSER"  \
            --file "$OPTIONS" \
            --get-all-values-in-section \
            --section "$iniSection"
    )"

    # The key in cmake_options are lowercase. Convert to uppercase
    # Format: key=value
    local pair key value

    if [ -n "$build_options" ]; then
        while read line; do
            IFS='=' read -ra pair <<< "$line"
            key="${pair[0]}"
            value="${pair[1]}"

            # Uppercase the key
            key="$( printf '%s' "$key" | tr '[:lower:]' '[:upper:]' )"
            cmake_options+=( "$key=$value" )
        done < <( printf '%s\n' "$build_options")
    fi

    return 0
}
