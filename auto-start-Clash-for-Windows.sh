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
cd /etc/init.d
update-rc.d cfw remove
rm cfw

# generate auto start script
cat > cfw << END_TEXT
#!/bin/sh


### BEGIN INIT INFO
# Required-Start:    $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

LOG_DIR=/var/log/cfw
${CLASH_DIR%%/}/cfw
if ! test -e \$LOG_DIR
then
  mkdir \$LOG_DIR
fi
echo "start successfully" >> \$LOG_DIR/\$(date +"%Y-%m-%d-%H-%M-%S").txt
END_TEXT
    
# use update-rc service to achieve it
chmod +x cfw
update-rc.d cfw defaults