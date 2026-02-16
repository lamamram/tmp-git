"""
functions to simulate elements of fake scripts to test git operations on them.

add_script:
   params:
    - name: name of the script 

add_function:
   params:
    - script_name: name of the script to add the function to
    - name: name of the function
    - lorem: placeholder text for the function body
"""
import sys
import random

LOREM = """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit.
    Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
    Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
    Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit.
    Anim id est laborum.
"""

def add_script(name):
    with open(f"script_{name}.txt", "w") as f:
        f.write(f"# script {name}\n\n")

def add_function(script_name, name, line_offset=1):
    with open(f"script_{script_name}.txt", "a") as f:
        for _ in range(line_offset):
            f.write("\n")
        f.write(f"function_{script_name}_{name}()" + "{\n")
        limit = random.randint(61, len(LOREM))
        f.write(f"    code{script_name}_{name} '{LOREM[:60] + LOREM[61:limit]}\n    '\n")  
        f.write("}\n")

def init_script_function(script_name):
    add_script(script_name)
    add_function(script_name, script_name)

if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "init":
        init_script_function(sys.argv[2])
    elif len(sys.argv) > 3 and sys.argv[1] == "add":
        add_function(sys.argv[2], sys.argv[3])
    else:
        sys.exit("Invalid command. Usage: python tools.py init <script_name> OR python tools.py add <script_name> <function_name>")
else:
    sys.exit("Not enough arguments. Usage: python tools.py init <script_name> OR python tools.py add <script_name> <function_name>")