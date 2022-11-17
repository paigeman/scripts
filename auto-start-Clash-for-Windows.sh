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
if ! test -e ${CLASH_DIR%%/}/cfw
then
    echo "directory is not right, please check"
    exit 1
fi

# remove cfw service
cd ~/.config/autostart
rm cfw.desktop

# generate auto start script
cat > cfw.desktop << END_TEXT
[Desktop Entry]
    Type=Application
    Version=0.20.6
    Name=Clash for Windows
    Comment=Clash for Windows startup script
    Exec=${CLASH_DIR%%/}/cfw --no-sandbox
    StartupNotify=false
    Terminal=false
END_TEXT