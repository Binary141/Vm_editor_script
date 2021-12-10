# Vm_editor_script

This script will modify the ip address, create a specified user with password, make the user able to run sudo, import any ssh keys that it may need, and set the hostname of the machine. This is intended to be used with vm clones of ubuntu with a preset ip address. This file can be placed on a vm before it is converted to a template, then after cloning this script can be run to automate the setup process.
