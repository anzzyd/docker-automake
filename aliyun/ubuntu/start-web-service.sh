#! /bin/sh -e
### BEGIN INIT INFO
# Provides:          cyd-web-services
# Required-Start:    $time $local_fs $remote_fs
# Required-Stop:     $time $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: CYD-WebServices daemon
# Description:       CYD-WebServices
### END INIT INFO

/usr/local/sbin/php-fpm
/usr/local/openresty/bin/openresty
rsync --daemon