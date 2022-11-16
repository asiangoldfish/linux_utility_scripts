# Dual Monitor

The dual-monitor.sh script is intended to be used on laptops connected to an external monitor. It will prompt `xrandr` to turn off the laptop monitor.

To use the script, change the value of `MONITOR_INTERFACE` to your laptop's interface name. You can use the `xrandr` command to find its name.

The script must be executed after connecting to the external monitors.