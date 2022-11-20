# Safe rm

Although not nearly powerful as `rm`, Safe rm stores deleted files and directories in the paperbin. This allows recovering the file to its original location.

# Table of Content
- [Usage](#usage)
- [Installation](#installation)
- [Commands](#commands)
- [How It Works](#how-it-works)
- [License](#license)
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
| del -l | List all files in the paperbin and their origin |
| del -e | Empty the paperbin |

# How It Works
In the user's home directory, a new directory `Paperbin` is created. All "deleted" files and directories is placed here. A records file is also created as `~/.config/safe_rm/record.txt`. The script only supports deleting file which the user has write access to. There is no plan to change this behaviour.

# License
The MIT License (MIT)
Copyright © 2022 Khai Duong

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# TODOs
- Implement file and directory checksums before moving them to the paperbin