####
# List workspaces or profiles
####
function list() {
    local arg="$1"
    
    # Parse arg
    case $arg in
        # If profiles, then list all saved profiles
        "profiles" ) i3-resurrect ls profiles; return "$?" ;;
        * )
            # We only accept no arg if profiles wasn't passed
            if [ -n "$arg" ]; then
                echo "list: unrecognized command $1"
            fi
            ;;
    esac

    i3-resurrect ls
    return "$?"
}