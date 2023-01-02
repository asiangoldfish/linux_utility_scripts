#!/usr/bin/bash

# Create a new project with this script

NAME="$( basename "$0" )"

# Directories to include in the new project
NEW_DIRS=(
)

NEW_FILES=(
    "README.md"
    "newfile.txt"
)

function usage() {
    echo -n "Usage: $NAME [OPTION] ...

$NAME, a management script for blender projects

Options:
    -h, --help              this page
    -n, --new-project       new project
"

    return 0
}

# Create new project containing named directories
function new_project() {
    DIRNAME="$1"

    # Check whether the directory name was passed
    if [ -z "$DIRNAME" ]; then
        printf '%s: The new directory should have a name\n' "$NAME"
        return 1
    
    # Check whether the directory already exists
    elif [ -d "$DIRNAME" ] || [ -f "$DIRNAME" ]; then
        printf "%s: \'%s\' already exists. Choose another name\n" \
            "$NAME" \
            "$DIRNAME"
        return 1
    fi

    # Create new directory
    mkdir "$DIRNAME" ||
        { printf "%s: Failed to create %s\n" "$NAME" "$DIRNAME"; \
            return 1; }

    # Create new directories
    if [[ "${#NEW_DIRS[@]}" -gt 0 ]]; then
        for dir in "${NEW_DIRS[@]}"; do
            mkdir -p "$DIRNAME/$dir" 2> /dev/null \
            printf "Could not create \'%s\'\n" "$dir"
        done
    fi

    # Create new files
    if [[ "${#NEW_FILES[@]}" -gt 0 ]]; then
        for file in "${NEW_FILES[@]}"; do
            touch "$DIRNAME/$file" 2> /dev/null || \
            printf "Could not create \'%s\'\n" "$file"
        done
    fi

    #####
    # Create any custom functions here
    ####
    populate_readme

    return 0
}

function populate_readme() {
    cat <<EOF > "$DIRNAME/README.md"
# $DIRNAME
EOF

    return 0
}

# Help page when running without arguments
if [ "$#" == 0 ]; then
    usage
    exit 0
fi

# Loop arguments
for arg in "$@"; do
    case "$arg" in
    "-h" | "--help" )
        usage
        break;;
    "-n" | "--new-project" )
        new_project "$2"
        break;;
    * )
        echo "$NAME: Unrecognized command $arg. Use --help for commands"
        break;;
    esac
done
