# Full Upgrade

The _fullupdate.sh_ script's intension is to fully upgrade the system with
a single command. To add or edit your system's update/upgrade command, do
the following:
1. Add a variable with your system's name (use lsb_release -i to find it) and
the full command to update/upgrade the system. Example:

    ```sh
    Debian="sudo apt update && sudo apt upgrade"
    ```
2. In the `fullUpgrade` function, find the case-block where commands are
executed. This code block will execute code dependending on what type of system
you're currently using. This means you can tailor the script across your Linux
devices indepdendently of their distribution. Add the following line, but
changing the name and command according to your needs:

    ```sh
    # case dep in "${DEPS[@]}"; do
    'Debian') eval "$Debian";;
    # done
    ```