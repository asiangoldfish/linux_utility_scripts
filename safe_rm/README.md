# Safe rm

Although not nearly powerful as `rm`, Safe rm stores deleted files and 
directories in the paperbin. This allows recovering the file to its original
location.

# Table of Content
- [Usage](#usage)
- [Installation](#installation)
- [Commands](#commands)
- [How It Works](#how-it-works)
- [The Record File](#the-record-file)
- [TODOs](#todos)

# Usage
```
Usage: del [OPTIONS] files...

Moves files to the paperbin for review instead of permanently deleting them.

OPTIONS:
    -e, --empty-bin         empty the paperbin
    -h, --help              this page
    -l, --list              list all items in the paperbin
    -r, --recursive         moves non-empty directory to paperbin

```

# Installation
The script requires no installation. Add it to PATH and it's ready for use!

```
git clone https://github.com/asiangoldfish/safe_rm.git
echo 'PATH:"$PATH:$HOME/safe_rm"' >> ~/.bashrc
```

Restart the shell or source .bashrc to get started:
```
source ~/.bashrc
```

# Commands
| Command | Description |
|:--------|:------------|
| del [files/directories] | List all files and directories to delete |
| del -r | To remove non-empty directories, the `-r` flag must be included |
| del -l | List all files in the paperbin, similarly to the `ls` command |
| del -e | Empty the paperbin |
| del --print-record | Prints all content in the record file |

# How It Works
In the user's home directory, a new directory `Paperbin` is created. All
"deleted" files and directories is placed here. A records file is also created
as `~/.config/safe_rm/record.txt`. The script only supports deleting file which
the user has write access to. There is no plan to change this behaviour.

# The Record File
There is an automatically generated file called `Record` in the
`~/.config/safe_rm` directory. This contains a list of all deleted files with
their original file path and checksum. *safe_rm* generates the checksum based on
the two following conditions:

- If the file is a directory, then:
    1. Uses the `tar` command to archive it
    2. Generates the archive file's MD5 checksum
- If the file is indeed a file, then:
    1. Directly generates the file's MD5 checksum.

# TODOs
[x] Implement file and directory checksums before moving them to the paperbin  
[ ] Implement feature to restore files back to their original path  
