#!/bin/sh
echo -e "\033[36m\033[1m=====================================================================\033[0m"
echo -e "\033[36m\033[1m[信息]Docker环境\033[33m OpenResty + PHP7 + Swoole + Redis \033[36m一键部署\033[33m By anzzyd \033[36m适用于\033[33m Ubuntu 16.04\033[0m"
echo -e "\033[36m\033[1m[信息]最后更新：\033[33m2019-07-04\033[0m"
echo -e "\033[36m\033[1m[信息]OpenResty版本：\033[33m1.15.8.1\033[0m"
echo -e "\033[36m\033[1m[信息]PHP版本：\033[33m7.3.6\033[0m"
echo -e "\033[36m\033[1m[信息]Swoole版本：\033[33m4.3.5\033[0m"
echo -e "\033[36m\033[1m[信息]Redis版本：\033[33m4.3.0 stable\033[0m"
echo -e "\033[36m\033[1m=====================================================================\033[0m"

echo -e "\033[32m\033[1m【警告】请确保在全新环境中执行该脚本，是否继续？\033[0m"
stty erase '^H' && read -p "(默认: n):" start_build
if [ ${start_build} != "y" ] ; then
    exit
fi

echo -e "\033[32m\033[1m【信息】是否安装Swoole扩展？\033[0m"
stty erase '^H' && read -p "(默认: n):" install_swoole

echo -e "\033[32m\033[1m【信息】是否安装Redis扩展？\033[0m"
stty erase '^H' && read -p "(默认: n):" install_redis_extension

#echo "是否安装Redis Server？(y/n)"
#stty erase '^H' && read -p "(默认: n):" install_redis

echo -e "\033[32m\033[1m【信息】是否开启Zend OPcache？\033[0m"
stty erase '^H' && read -p "(默认: n):" load_opcache

cd /opt
apt-get update

echo -e "\033[32m\033[1m【信息】正在准备依赖项\033[0m"
apt-get install -y wget && \
apt-get install -y make && \
apt-get install -y gcc && \
apt-get install -y libpcre3-dev && \
apt-get install -y libssl-dev && \
apt-get install -y perl && \
apt-get install -y build-essential && \
apt-get install -y libpcre3 && \
apt-get install -y zlib1g && \
apt-get install -y zlib1g-dev && \
apt-get install -y libssl-dev && \
apt-get install -y curl && \
apt-get install -y vim && \
apt-get install -y libxml2-dev && \
apt-get install -y autoconf && \
apt-get install -y libcurl4-gnutls-dev && \
apt-get install -y rsync && \
apt-get install -y inotify-tools

#echo "[信息]安装常用工具"
#apt-get install -y net-tools

if [ ! -f "/opt/openresty-1.15.8.1.tar.gz" ];then
    echo -e "\033[32m\033[1m【信息】开始下载OpenResty...\033[0m"
    wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/package/openresty-1.15.8.1.tar.gz -O openresty-1.15.8.1.tar.gz
fi

tar -xvf openresty-1.15.8.1.tar.gz
cd openresty-1.15.8.1
echo -e "\033[32m\033[1m【信息】开始编译OpenResty...\033[0m"
./configure --with-http_v2_module
make && make install

cd ..

if [ ! -f "/opt/php-7.3.6.tar.gz" ];then
    echo -e "\033[32m\033[1m【信息】开始下载PHP7.3.6...\033[0m"
    wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/package/php-7.3.6.tar.gz -O php-7.3.6.tar.gz
fi

tar -xvf php-7.3.6.tar.gz
cd php-7.3.6
echo -e "\033[32m\033[1m【信息】开始编译PHP7.3.6...\033[0m"
./configure --enable-fpm --with-curl --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-fpm-user=nginx --with-fpm-group=nginx
make && make install

echo -e "\033[32m\033[1m【信息】正在处理PHP环境...\033[0m"
#mv /usr/local/etc/php-fpm.d/www.conf.default /usr/local/etc/php-fpm.d/www.conf
cd /usr/local/etc/php-fpm.d/
wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/www.conf -O www.conf
cd /usr/local/etc/
wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/php-fpm.conf -O php-fpm.conf

echo -e "\033[32m\033[1m【信息】创建php.ini(生产环境)\033[0m"
cp /opt/php-7.3.6/php.ini-production /usr/local/lib/
mv /usr/local/lib/php.ini-production /usr/local/lib/php.ini

echo -e "\033[32m\033[1m【信息】正在设置error_log目录...\033[0m"
mkdir /opt/php_errors
chmod 755 /opt/php_errors
echo "#Added by build.sh" >> /usr/local/lib/php.ini
echo "error_log = /opt/php_errors/log.txt" >> /usr/local/lib/php.ini

echo -e "\033[32m\033[1m【信息】设置时区为PRC\033[0m"
echo "#Added by build.sh" >> /usr/local/lib/php.ini
echo "date.timezone=PRC" >> /usr/local/lib/php.ini

echo -e "\033[32m\033[1m【信息】创建nginx用户...\033[0m"
useradd nginx

echo -e "\033[32m\033[1m【信息】正在从OSS中拉取nginx.conf...\033[0m"
cd /usr/local/openresty/nginx/conf/
wget http://cyd-server-config.oss-cn-beijing.aliyuncs.com/nginx.conf -O nginx.conf
mkdir /opt/www

echo -e "\033[32m\033[1m【信息】已将网站默认目录改为 /opt/www/\033[0m"

echo -e "\033[32m\033[1m【信息】创建测试文件...\033[0m"
cd /opt/www
echo "OpenResty Running..." > index.html
echo "<?php echo 'Hello world'; ?>" > index.php

#if [ ${install_redis} = "y" ] ; then
#    echo "[信息]正在安装Redis Server..."
#    apt-get install -y redis-server
#    echo "[信息]正在处理Redis配置..."
#    cd /etc/redis/
#    wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/redis.conf -O redis.conf
#    service redis-server restart
#fi

if [ ${install_swoole} = "y" ] ; then
    echo -e "\033[32m\033[1m【信息】开始安装Swoole扩展...\033[0m"
    cd /opt
    wget https://github.com/swoole/swoole-src/archive/v4.3.5.tar.gz -O v4.3.5.tar.gz
    tar -xvf v4.3.5.tar.gz
    cd swoole-src-4.3.5
    phpize
    ./configure
    make && make install

    echo "#Added by build.sh" >> /usr/local/lib/php.ini
    echo "extension=swoole" >> /usr/local/lib/php.ini

    echo -e "\033[32m\033[1m【信息】swoole.so现已加入肯德基全家桶\033[0m"
fi

if [ ${load_opcache} = "y" ] ; then
    echo "#Added by build.sh" >> /usr/local/lib/php.ini
    echo "zend_extension=opcache" >> /usr/local/lib/php.ini
    echo -e "\033[32m\033[1m【信息】Zend opcache现已加入肯德基全家桶\033[0m"
fi

if [ ${install_redis_extension} = "y" ] ; then
    echo -e "\033[32m\033[1m【信息】正在下载Redis扩展...\033[0m"
    cd /opt
    wget https://pecl.php.net/get/redis-4.3.0.tgz -O redis-4.3.0.tgz
    tar -xvf redis-4.3.0.tgz
    cd redis-4.3.0
    echo -e "\033[32m\033[1m【信息】正在编译Redis扩展...\033[0m"
    phpize
    ./configure
    make && make install

    echo -e "\033[32m\033[1m【信息】Redis扩展安装完成\033[0m"

    echo "#Added by build.sh" >> /usr/local/lib/php.ini
    echo "extension=redis" >> /usr/local/lib/php.ini
    echo -e "\033[32m\033[1m【信息】redis.so现已加入肯德基全家桶\033[0m"
fi

echo -e "\033[32m\033[1m【信息】正在配置rsync server...\033[0m"
echo "rsync_www:6wfOm5uTi2ZY2NFn" > /etc/rsyncd-recv.password
chmod 600 /etc/rsyncd-recv.password
cd /etc
wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/aliyun/ubuntu/rsyncd.conf -O rsyncd.conf
rm /var/run/rsyncd.pid
rsync --daemon
echo -e "\033[32m\033[1m【信息】rsync配置完毕\033[0m"
cd

echo -e "\033[32m\033[1m【信息】配置拉取密码中...\033[0m"
echo "6wfOm5uTi2ZY2NFn" > /etc/rsyncd-pull-from-master.password
chmod 600 /etc/rsyncd-pull-from-master.password
echo -e "\033[32m\033[1m【信息】开始拉取最新项目文件...\033[0m"
rsync -avzh --password-file=/etc/rsyncd-pull-from-master.password rsync_www@172.17.210.141::cydpull /opt/www
echo -e "\033[32m\033[1m【信息】拉取项目文件完成!\033[0m"

echo -e "\033[32m\033[1m【信息】设置目录归属为nginx...\033[0m"
chown nginx:nginx -R /opt/www
chown nginx:nginx -R /opt/php_errors

echo -e "\033[32m\033[1m【信息】正在启动PHP7...\033[0m"
/usr/local/sbin/php-fpm

echo -e "\033[32m\033[1m【信息】正在启动OpenResty...\033[0m"
/usr/local/openresty/bin/openresty -s stop
/usr/local/openresty/bin/openresty

echo -e "\033[32m\033[1m【信息】测试静态页结果:\033[0m"
curl http://127.0.0.1
echo -e "\033[32m\033[1m【信息】测试PHP页结果:\033[0m"
curl http://127.0.0.1/index.php

#优化内核
echo -e "\033[32m\033[1m【信息】拉取 & 优化Linux内核参数...\033[0m"
echo "ulimit -n 1024576" >> /etc/security/limits.conf
cd /etc
wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/aliyun/ubuntu/sysctl.conf -O sysctl.conf
chmod 644 sysctl.conf
echo -e "\033[32m\033[1m【信息】内核参数优化完成!\033[0m"

echo -e "\033[32m\033[1m【信息】正在安装探针...\033[0m"
cd /opt
wget https://raw.githubusercontent.com/anzzyd/cyd_cluster_servers_reporter/master/cyd_reporter.php -O cyd_reporter.php

echo -e "\033[32m\033[1m【信息】正在配置开机启动...\033[0m"
cd /etc/init.d
wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/aliyun/ubuntu/start-web-service.sh -O start-web-service.sh
chmod 755 start-web-service.sh
update-rc.d start-web-service.sh defaults 90
echo -e "\033[34m\033[1m【信息】开机启动配置完成\033[0m"

echo -e "\033[34m\033[1m【信息】所有项目均部署完成，正在重启操作系统...\033[0m"
echo -e "\033[34m\033[1m【信息】网站默认目录为：/opt/www/\033[0m"

reboot

#if [ ${install_redis} = "y" ] ; then
#    echo "[信息]Redis端口为：16379(已开启UNIX Socket)"
#fi

# 备用
# crontab -l > conf && echo "* * * * * echo go123 >> /opt/test.txt" >> conf && crontab conf && rm -f conf