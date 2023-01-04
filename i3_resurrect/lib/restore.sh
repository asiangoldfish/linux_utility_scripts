#######################################
# Restore workspace by index
#
# Globals
#   HOME: The user's home directory
#
# Arguments:
#   None
#######################################
function restore() {
    # Immediately quit if there's nothing to restore
    if [ -d "$HOME/.i3/i3-resurrect" ]; then
        if [ ! "$(ls -A $HOME/.i3/i3-resurrect)" ]; then
            echo "Nothing to restore from"
            return 1
        fi
    else
        echo "Nothing to restore from"
        return 1
    fi

    initialize || return "$?"

    local workspace="$1"     # Workspace to save

    # Assign current workspace as the one to save if none was passed
    if [ -z "$workspace" ]; then
        workspace="$( i3-msg -t get_workspaces |
                        jq -r '.[] | select(.focused==true).name' )"
    fi

    # Restore workspaces
    echo "Restoring workspaces:"
    i3-resurrect restore -w "$workspace"
    echo "Workspace $workspace [Complete]"

    return 0
}

#######################################
# Restore all workspaces
#
# Globals
#   HOME: The user's home directory
#
# Arguments:
#   None
#######################################
function restore_all() {
    # Immediately quit if there's nothing to restore
    if [ -d "$HOME/.i3/i3-resurrect" ]; then
        if [ ! "$(ls -A $HOME/.i3/i3-resurrect)" ]; then
            echo "Nothing to restore from"
            return 1
        fi
    
    else
        echo "Nothing to restore from"
        return 1
    fi

    initialize || return "$?"

    # Get all used workspaces
    local used_workspaces="$( cat $TRACKER )"
    local i
    local IFS=$'\n'
    
    # Restore workspaces
    echo "Restoring workspaces:"
    echo "$used_workspaces" | while read -r i; do
        i3-resurrect restore -w "$i"
        echo "Workspace $i [Complete]"
    done

    # Automatically go to workspace 1
    #i3-msg workspace number 1

    echo -e "\nClearing saved workspaces..."
    echo "$used_workspaces" | while read -r j; do
        i3-resurrect rm -w "$j"
    done
    
    rm "$TRACKER"
}