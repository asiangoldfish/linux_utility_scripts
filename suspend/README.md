# Suspend

Intended for window managers. While desktop environments provide ways to manage the device's power state, most window managers out-of-the-box won't do that. The scripts in this directory aids in suspending the device.

`powersuspend.sh` calls the `systemctl` command. If your operating system does not use systemd or the script won't work, then optionally you may use `suspend.sh`
