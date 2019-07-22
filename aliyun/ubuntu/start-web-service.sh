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

rsync --daemon
rsync -avzh --password-file=/etc/rsyncd-pull-from-master.password rsync_www@master.ip::cydpull /opt/www &
chown nginx:nginx -R /opt/www
/usr/local/sbin/php-fpm
/usr/local/openresty/bin/openresty
if [ -f "/var/run/rsyncd.pid" ];then
    rm /var/run/rsyncd.pid
fi
php /opt/cyd_reporter.php &
chown nginx:nginx /opt/php_errors/log.txt
curl 'http://master.ip:50555' --data "method=\backend\log\ServerLog&run=put&log_from=start-web-service.sh&log_content=Service Started&log_server=$(cat /etc/hostname)"