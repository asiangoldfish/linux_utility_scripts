#!/usr/bin/bash

NUM_OF_WORKSPACE=9
KEEP_WORKSPACES=false

# Save workspaces 
if [ "$1" == "--save" ]; then
    echo "Saving workspaces:"
    for i in $(seq 1 $NUM_OF_WORKSPACE); do
        i3-resurrect save -w "$i"
        echo "Workspace $i [Complete]"
    done

# Restore workspaces
elif [ "$1" == "--restore" ]; then
    echo "Restoring workspaces:"
    for i in $(seq $NUM_OF_WORKSPACE 1); do
        i3-resurrect restore -w "$i"
        echo "Workspace $i [Complete]"
    done

    # Automatically clear all saved workspaces after restoring them
    if [ "$KEEP_WORKSPACES" == "false" ]; then
        echo "Clearing saved workspaces..."
        for i in $(seq 1 $NUM_OF_WORKSPACE); do
            i3-resurrect rm -w "$i"
        done
    fi

# Error message if the caller did not provide save or restore mode
else
    echo "$( basename $0 ): Use --save or --restore to specify mode"
fi
