#!/bin/sh
echo "====================================================================="
echo "[信息]Docker环境OpenResty+PHP7+Swoole一键部署 By anzzy 适用于Ubuntu 16.04"
echo "[信息]最后更新：2019-06-19"
echo "[信息]OpenResty版本：1.15.8.1"
echo "[信息]PHP版本：7.3.6"
echo "[信息]Swoole版本：4.3.5"
echo "====================================================================="

echo "[警告]请在全新环境中执行该脚本，是否继续？(y/n)"
stty erase '^H' && read -p "(默认: n):" start_build
if [ ${start_build} != "y" ] ; then
    exit
fi

echo "是否安装Swoole扩展？(y/n)"
stty erase '^H' && read -p "(默认: n):" install_swoole

#echo "是否安装cURL扩展？(y/n)"
#stty erase '^H' && read -p "(默认: n):" install_curl

#echo "是否安装mysqli扩展？(y/n)"
#stty erase '^H' && read -p "(默认: n):" install_mysqli

cd /opt
apt-get update

echo "[信息]正在准备依赖项"
apt-get install -y wget
apt-get install -y make
apt-get install -y gcc
apt-get install -y libpcre3-dev
apt-get install -y libssl-dev
apt-get install -y perl
apt-get install -y build-essential
apt-get install -y libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev
apt-get install -y curl
apt-get install -y redis-server
apt-get install -y vim
apt-get install -y libxml2-dev
apt-get install -y autoconf

#echo "[信息]安装常用工具"
#apt-get install -y net-tools

echo "[信息]开始下载OpenResty..."
wget https://openresty.org/download/openresty-1.15.8.1.tar.gz
tar -xvf openresty-1.15.8.1.tar.gz
cd openresty-1.15.8.1
echo "[信息]开始编译OpenResty..."
./configure
make && make install

cd ..

echo "[信息]开始下载PHP7.3.6..."
wget https://www.php.net/distributions/php-7.3.6.tar.gz
tar -xvf php-7.3.6.tar.gz
cd php-7.3.6
echo "[信息]开始编译PHP7.3.6..."
./configure --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx
make && make install

echo "[信息]正在处理PHP环境..."
mv /usr/local/etc/php-fpm.d/www.conf.default /usr/local/etc/php-fpm.d/www.conf
cd /usr/local/etc/
wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/php-fpm.conf
chmod 777 php-fpm.conf

echo "[信息]创建php.ini(生产环境)"
cp /opt/php-7.3.6/php.ini-production /usr/local/lib/
mv /usr/local/lib/php.ini-production /usr/local/lib/php.ini

echo "[信息]创建nginx用户..."
useradd nginx

echo "[信息]正在处理OpenResty nginx.conf"
cd /usr/local/openresty/nginx/conf/
wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/nginx.conf -O nginx.conf
mkdir /opt/www
echo "[信息]已将网站默认目录改为 /opt/www/"

echo "[信息]创建测试文件..."
cd /opt/www
echo "OpenResty Running..." > index.html
echo "<?php echo 'PHP Working';?>" > index.php

echo "[信息]正在处理Redis配置..."
cd /etc/redis/
wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/redis.conf -O redis.conf
service redis-server restart

if [ ${install_swoole} = "y" ] ; then
    echo "[信息]开始安装Swoole扩展..."
    cd /opt
    wget https://github.com/swoole/swoole-src/archive/v4.3.5.tar.gz
    tar -xvf v4.3.5.tar.gz
    cd swoole-src-4.3.5
    phpize
    ./configure
    make && make install

    echo "#Added by build.sh (https://github.com/anzzyd/docker-automake)" >> /usr/local/lib/php.ini
    echo "extension=swoole" >> /usr/local/lib/php.ini
fi

echo "[信息]正在启动PHP7..."
/usr/local/sbin/php-fpm

echo "[信息]正在启动OpenResty..."
/usr/local/openresty/bin/openresty -s stop
/usr/local/openresty/bin/openresty

echo "[信息]测试静态页结果:"
curl http://127.0.0.1
echo "[信息]测试PHP页结果:"
curl http://127.0.0.1/index.php

echo "[信息]所有项目均部署完成"
echo "[信息]网站默认目录为：/opt/www/"
echo "[信息]Redis端口为：16379(已开启UNIX Socket)"