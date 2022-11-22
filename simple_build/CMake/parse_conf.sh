
# Parses CMake options
function parse_cmake_options() {
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
