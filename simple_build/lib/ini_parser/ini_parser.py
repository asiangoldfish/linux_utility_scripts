#!/usr/bin/python3

"""
MIT License

Copyright (c) 2022 Khai Duong

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

"""
The script parser.py is a single-file initialization (ini) file parser and
is a wrapper for the Python configparser module.
"""

# Exit codes:
#   0: This script executed successfully
#   1: The configuration file could not be found
#   2: An argument expected a value but had none
#   3: The function name passed as argument is invalid
#   4: Script was executed with invalid arguments [VALUES]
#   5: No config file path was passed
#   6: Argument '--value' requires a valid section and key

from sys import exit as sysexit                         # exit script
from sys import argv                                    # handle script args
from pathlib import Path                                # get file paths
from configparser import ConfigParser                   # parse ini file
from configparser import NoSectionError                 

exit_code = 0                                           # exit code to stderr

script_path = Path(__file__).resolve().parent           # this script's path

config = ConfigParser()
config_path = ""


def check_missing_value(arg: str):
    """
    Checks if a string's value is missing

    If the value is missing, then print an error
    message

    Parameters:
        arg (str): argument to parse
    Returns:
        [str, int]: (modified arg string as array, error code)
    """

    # arg and value is split
    arg = arg.split('=', 1)
    if len(arg) == 2 and arg[1] != "":
        return [arg[1], 0]
    else:
        return [0, 2]


def get_all_nested_sections_str(arg_vars: str):
    """
    Gets all nested sections in one line of string

    Based on a parent name, gets all nested sections.
    Example: func_name('foo_parent/bar_subparent')

    Parameters:
        parent (str): Parent sections to base the
                      search on
    Returns:
        str: All nested sections based on the given
             parameters
    """
    
    for elem in config.sections():
        if arg_vars['--pattern'] in elem:
            print(elem)


def validate_arg(argv: list, arg_vars: dict, arg):
    if (i + 1 < len(argv)):
        if (argv[i + 1] in arg_vars.keys()):
            print('Missing argument:', arg)
            sysexit(2)
    else:
        print(f'Missing argument: {arg}')
        sysexit(2)


def set_exit_code(num: int):
    """
    Sets this script's error code.

    Parameters:
        num (int): The number to set as error code
    """

    global exit_code
    exit_code = num


def get_all_values_in_section(arg_dict: dict):
    """Gets all values belonging to the named section
    
    Parameters:
        - arg_dict (dict): dictionary containing section and key to search for
                           value
    Return:
        str: Values based on input section
    """
    try:
        value = {k:v for k,v in config.items(arg_dict['--section'])}
        for x in value.items():
            print(x[0] + '=' + x[1])
    except NoSectionError:
        print('parser.py: Argument \'--get-all-values-in-section\' requires a valid section')
        set_exit_code(6)
        return
    set_exit_code(0)



def get_exit_code():
    """
    Gets the exit code

    Returns:
        int: Exit code
    """

    return exit_code


def get_value(arg_dict: dict):
    """
    Gets a the value of a given key in a section.

    Parameters:
        - arg_dict (dict): dictionary containing section and key to search for
                           value
    Return:
        str: Value based on section and key
    """
    
    try:
        value = config.get(arg_dict['--section'], arg_dict['--key'])
        print(value)
    except NoSectionError:
        print('parser.py: Argument \'--value\' requires valid section and key')
        set_exit_code(6)
        return
    set_exit_code(0)


def get_root_sections(section: dict):
    """Gets sections without any nested sections
    """

    for elem in config.sections():
        if not '/' in elem:
            print(elem)
    set_exit_code(0)

def usage():
    print("""parser.py [OPTION]
parser.py [OPTIONS] [VALUES]

This script is intended parses an initialization file and outputs results
to stdout.

To learn more about what each option does and arguments it requires,
use the help flag with it.

Example: parser.py --value --help

Options:
    -h, --help                                  this page
        --root-sections                         gets the parent sections
        --search-section [pattern]              search for sections with regex
        --value [section] [key]                 gets the value from a given section and key
        --version                               outputs version information and exit
        --get-all-values-in-section             gets all values within a section

Values:
        --pattern                               parent of nested sections
        --section                               definite section to use
        --file                                  target initialization file to parse
""",
          end='')
    set_exit_code(0)


# call usage if no arguments were passed
if len(argv) == 1:
    usage()
    sysexit(get_exit_code())

# let script execution call functions based on the script argv
arg_vars = {
    '--debug': '',
    '--file': '',
    '--key': '',
    '--pattern': '',
    '--section': '',
}

# we create a hard copy of argv to avoid manipulating it
process_argv = argv.copy()
# remove file name in arr
process_argv.pop(0)

# stores the identifier to invoke a given function at a later point when all
# arguments have been parsed
skip_arg = False

for i, arg in enumerate(process_argv):
    if not skip_arg:
        match arg:
            case '--get-all-values-in-section':
                execute_function = get_all_values_in_section
            # match functions
            case '-h' | '--help':
                usage()
            case '--root-sections':
                execute_function = get_root_sections
            case '--search-section':
                execute_function = get_all_nested_sections_str
            case '--value':
                execute_function = get_value

            # match arguments
            case '--debug':
                if i + 1 < len(argv):
                    next_arg = argv[i + 1]
                    if next_arg in arg_vars.keys():
                        if next_arg != True or False:
                            print(f'Argument {arg} requires argument True or False')
                            sysexit(2)

                arg_vars['--debug'] = process_argv[i + 1]
                skip_arg = True

            case '--file':
                validate_arg(process_argv, arg_vars, arg)
                arg_vars['--file'] = process_argv[i + 1]
                skip_arg = True
            case '--key':
                validate_arg(process_argv, arg_vars, arg)
                arg_vars['--key'] = process_argv[i + 1]
                skip_arg = True
            case '--pattern':
                validate_arg(process_argv, arg_vars, arg)
                arg_vars['--pattern'] = process_argv[i + 1]
                skip_arg = True
            case '--section':
                validate_arg(process_argv, arg_vars, arg)
                arg_vars['--section'] = process_argv[i + 1]
                skip_arg = True
    else:
        skip_arg = False

# read the config file
read_configs = config.read(arg_vars['--file'])

# if config file was unsuccessfully read, then exit the program
if len(read_configs) == 0:
    print('No configuration file was passed')
    sysexit(5)

try:
    execute_function(arg_vars)
except NameError:
    print(f'{argv[0]}: No actions to execute. Use \'{argv[0]} --help\' for a list of commands')

sysexit(get_exit_code())