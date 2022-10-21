#!/bin/sh


### BEGIN INIT INFO
# Required-Start:    $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

LOG_DIR=/var/logs/sync-time
ntpdate ntp.aliyun.com
hwclock -w
if ! test -e $LOG_DIR
then
  mkdir $LOG_DIR
fi
cd $LOG_DIR
echo "sync finished" >> $(date +"%Y-%m-%d-%H-%M-%S").txt
