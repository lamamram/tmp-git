#!/bin/bash

# Functions to simulate elements of fake scripts to test git operations on them.
#
# add_script:
#    params:
#     - name: name of the script 
#
# add_function:
#    params:
#     - script_name: name of the script to add the function to
#     - name: name of the function
#     - lorem: placeholder text for the function body

LOREM="
    Lorem ipsum dolor sit amet, consectetur adipiscing elit.
    Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
    Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
    Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit.
    Anim id est laborum.
"

add_script() {
    local name=$1
    echo "# script $name" > "script_${name}.txt"
    echo "" >> "script_${name}.txt"
}

add_function() {
    local script_name=$1
    local name=$2
    local line_offset=${3:-1}
    
    # Add empty lines based on line_offset
    for ((i=0; i<line_offset; i++)); do
        echo "" >> "script_${script_name}.txt"
    done
    
    # Add function header
    echo "function_${script_name}_${name}(){" >> "script_${script_name}.txt"
    
    # Generate random limit between 61 and length of LOREM
    local lorem_length=${#LOREM}
    local limit=$((61 + RANDOM % (lorem_length - 61)))
    
    # Extract substring (simulating the Python slicing)
    local lorem_part="${LOREM:0:60}${LOREM:61:$((limit-61))}"
    
    # Add function body
    echo "    code${script_name}_${name} '${lorem_part}" >> "script_${script_name}.txt"
    echo "    '" >> "script_${script_name}.txt"
    echo "}" >> "script_${script_name}.txt"
}

init_script_function() {
    local script_name=$1
    add_script "$script_name"
    add_function "$script_name" "$script_name"
}

# Main script logic
if [ $# -eq 2 ] && [ "$1" = "init" ]; then
    init_script_function "$2"
elif [ $# -gt 2 ] && [ "$1" = "add" ]; then
    add_function "$2" "$3"
else
    echo "Invalid command. Usage: bash tools.sh init <script_name> OR bash tools.sh add <script_name> <function_name>" >&2
    exit 1
fi
