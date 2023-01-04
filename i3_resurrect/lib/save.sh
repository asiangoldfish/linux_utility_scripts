#######################################
# Save a single workspace
#   
# Arguments:
#   $1 [POSITIONAL]: Index of workspace to save (default: current)
#######################################
function save() {
    initialize || return "$?"

    local workspace="$1"     # Workspace to save
    
    # Assign current workspace as the one to save if none was passed
    if [ -z "$workspace" ]; then
        workspace="$( i3-msg -t get_workspaces |
                        jq -r '.[] | select(.focused==true).name' )"
    fi

    # Create file that tracks saved workspaces
    manage_tracker --create

    i3-resurrect save -w "$workspace"   # Save workspace
    echo -ne "$workspace\n" >> "$TRACKER"       # Record saved workspace
    echo "Workspace $workspace was saved"       # Output log to screen
}

#######################################
# Save workspaces
#
# Loops through workspaces 1 through 9 and saves each of them. It will skip
# all empty workspaces
#   
# Arguments:
#   None
#######################################
function save_all() {
    initialize || return "$?"

    # Create file that tracks saved workspaces
    manage_tracker --recreate


    # Fetch all used workspaces
    local cmd="$( i3-msg -t get_workspaces | jq '.[].num' )"

    local IFS=$'\n'

    # Iterate each used workspace
    echo "Saving workspaces:"
    echo "$cmd" | while read -r i; do
        i3-resurrect save -w "$i"
        echo -ne "$i\n" >> "$TRACKER"
        echo "Workspace $i [Complete]"
    done
}

#######################################
# Save profile
#   
# Arguments:
#   $1: Profile name
#######################################
function save_by_profile() {
    local profile_name="$1"         # Profile name to save by
    local workspace="$2"            # Workspace to save
    
    # Assign current workspace as the one to save if none was passed
    if [ -z "$workspace" ]; then
        workspace="$( i3-msg -t get_workspaces |
                        jq -r '.[] | select(.focused==true).name' )"
    fi

    # Update tracker
    TRACKER="$TRACKER_DIR/../${profile_name}_tracker"

    # Create file that tracks saved workspaces
    manage_tracker --create

    # Check for empty profile name. If empty, then print error
    if [ -z "$profile_name" ]; then
        echo "$NAME: Missing profile name" > /dev/stderr
        return 1
    fi

    i3-resurrect save --profile "$profile_name" -w "$workspace"
    echo "Workspace $workspace saved as $profile_name"

}

#######################################
# Save all workspaces by profile
#   
# Arguments:
#   $1: Profile name
#######################################
function save_all_by_profile() {
    local profile_name="$1"         # Profile name to save by

    # Check for empty profile name. If empty, then print error
    if [ -z "$profile_name" ]; then
        echo "$NAME: Missing profile name" > /dev/stderr
        return 1
    fi

    # Update tracker
    TRACKER="$TRACKER_DIR/../${profile_name}_tracker"

    # Create file that tracks saved workspaces
    manage_tracker --recreate

    # Fetch all used workspaces
    local cmd="$( i3-msg -t get_workspaces | jq '.[].num' )"

    local IFS=$'\n'

    # Iterate each used workspace
    local workspace

    echo "Saving workspaces as $profile_name:"
    echo "$cmd" | while read -r workspace; do
        i3-resurrect save --profile "$profile_name" -w "$workspace"
        echo -ne "$workspace\n" >> "$TRACKER"
        echo "Workspace $workspace [Complete]"
    done

}