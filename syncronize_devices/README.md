# NCP

Synchronizes files between two devices. This is useful when you wish to syncronize certain directories between a laptop and desktop computers. You can use the same ncp.sh script on both devices and it'll automatically detect which address it's on by detecting the device's ip address.

## Limitations
The script uses the `rsync` command and updates a file if an update version of the named file exists. This is; however, cannot merge files. Changes on the older file will be overwritten. The script is therefore suited best when you work on one device at a time and setup an automated system for syncronizing them.

## Settin Up
The ncp.sh script requires manual ip address assignment. You can do this with the `DEVICE1` and `DEVICE2` variables at the top of the file. You also need to assign the username in `USER` and list directories to syncronize. This is done with the `DIRS` array.

## Usage

**Pull files**
```
ncp.sh -d
```

**Push files**
```
ncp.sh -u
```
