# Toggle Touchpad
Execute `toggle_touchpad.sh` to deactivate or activate your device's touchpad, if it supports it.

# How it works
The script depends on the file $HOME/.touchpad that stores either 0 or 1. This tells the script at what state the touchpad should be at, allowing the script to persist after logging off the GUI session.