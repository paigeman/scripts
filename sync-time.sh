#!/bin/sh


### BEGIN INIT INFO
# Required-Start:    $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

ntpdate ntp.aliyun.com
hwclock -w
