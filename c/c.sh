#!/usr/bin/bash

TMPDIR='./tmp'
CC='gcc'
DC='gdb'
OUT='a.out'

CFLAGS='-Wall -Wextra -g'

function usage()
{
    echo "Usage: c [OPTION]...
Compile a single file and execute it

Options:
    run             compile and execute the program
    debug           compile and execute with the program with GDB
    clean           clean temporary files and directories"
}
#    auto-compile    automatically compile on changes within \$PWD


function run()
{
    ## Compile and execute program
    
    local mode="$1"
    local filename="$3"
    local errno
    
    makeTmpDir
    verify "$filename"                                  # verify file existence
    
    errno="$?"
    if [ "$errno" != 0 ]; then exit; fi
    
    case "$mode" in
        'release' )
            "$CC" "$filename" -o "$TMPDIR"/"$OUT"       # compile
        ;;
        'debug' )
            "$CC" "$CFLAGS" "$1" -o "$TMPDIR"/"$OUT" &> /dev/null
        ;;
    esac
    
    errno="$?"
    if [ "$errno" != 0 ]; then exit; fi
    
    shift; shift;                                       # keep args only
    "$TMPDIR"/"$OUT" "$@"                             # execute with arguments
}


function verify()
{
    local file="$1"
    
    if [ -z "$file" ]; then
        echo "compile.sh: No files were given"
        return 1
    fi
    
    if [ ! -f "$file" ]; then
        printf "compile.sh: Could not find file \'$file\'\n"
        return 1
    fi
    
    return 0
}


function makeTmpDir()
{
    if [ ! -d "$TMPDIR" ]; then
        mkdir "$TMPDIR"
    fi
}


function clean()
{
    if [ -d "$TMPDIR" ]; then
        rm -r "$TMPDIR"
        echo "Removed $TMPDIR"
    fi
}

if [ -z "$1" ]; then
    usage
    exit
fi

# Take user input and execute functions accordingly
for arg in "$@"; do
    case "$arg" in
        #'auto-compile' ) auto_run "$@"; exit;;
        'debug' ) run 'debug' "$@"; exit;;
        'clean' ) clean; exit;;
        'run'   ) run 'release' "$@"; exit;;
        'help' | * ) usage; exit;;
    esac
    shift
done
