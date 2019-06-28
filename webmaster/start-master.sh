#! /bin/sh -e
### BEGIN INIT INFO
# Provides:          cyd-web-master-services
# Required-Start:    $time $local_fs $remote_fs
# Required-Stop:     $time $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: CYD-WebMaster-Services daemon
# Description:       CYD-WebMaster-Services
### END INIT INFO
rm /var/run/rsyncd.pid
rsync --daemon
/opt/sender.sh