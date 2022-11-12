#!/bin/sh

CLASH_DIR
# check where Clash-for-Windows is installed
echo "Please enter the dir where the Clash-for-Windows is installed:"
read CLASH_DIR
if ! test -e $CLASH_DIR
then
    echo "directory does not exist"
    exit 1
fi
if ! test -e $CLASH_DIR/cfw
then
    echo "directory is not right, please check"
    exit 1
fi
# generate auto start script

# use update-rc service to achieve it
