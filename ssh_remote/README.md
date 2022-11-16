# SSH Remote

remote.sh is a wrapper script for the `ssh` command. It's usage design is to effortly connect to an often used remote server. It's also designed to be sourced by your shell's configuration file.

## Sourcing to Shell Configurations

You can either add remote.sh manually with editors like nano or vim, or use commands directly.

**Bash**
```sh
PATH=""     # Enter the script's full filepath
echo "source $PATH" > ~/.bashrc
```

**zsh**
```sh
PATH=""     # Enter the script's full filepath
echo "source $PATH" > ~/.zshrc
```

## Usage
Connect to the remote server by calling the function directly from your terminal. Example:
```
server
```

You can also connect to another user than the default one.
```
server alice
```

## Adding More Targets
Each function represents one target to connect to. To add another target, simply duplicate a function and replace the empty `user` and `address` variables (the empty ones in remote.sh template).