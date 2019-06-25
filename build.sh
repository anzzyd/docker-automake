#!/bin/sh
echo "====================================================================="
echo "[信息]Docker环境OpenResty+PHP7+Swoole+Redis一键部署 By anzzy 适用于Ubuntu 16.04"
echo "[信息]最后更新：2019-06-25"
echo "[信息]OpenResty版本：1.15.8.1"
echo "[信息]PHP版本：7.3.6"
echo "[信息]Swoole版本：4.3.5"
echo "[信息]Redis版本：4.3.0 stable"
echo "====================================================================="

echo "[警告]请确保在全新环境中执行该脚本，是否继续？(y/n)"
stty erase '^H' && read -p "(默认: n):" start_build
if [ ${start_build} != "y" ] ; then
    exit
fi

echo "是否跳过OpenResty、PHP的下载过程？(y\n)"
stty erase '^H' && read -p "(默认: n):" skip_wget_download

echo "是否安装Swoole扩展？(y/n)"
stty erase '^H' && read -p "(默认: n):" install_swoole

echo "是否安装Redis扩展？(y/n)"
stty erase '^H' && read -p "(默认: n):" install_redis_extension

echo "是否安装Redis Server？(y/n)"
stty erase '^H' && read -p "(默认: n):" install_redis

echo "是否开启Zend OPcache？(y/n)"
stty erase '^H' && read -p "(默认: n):" load_opcache

cd /opt
apt-get update

echo "[信息]正在准备依赖项"
apt-get install -y wget make gcc libpcre3-dev libssl-dev perl build-essential libpcre3 zlib1g zlib1g-dev libssl-dev curl vim libxml2-dev autoconf libcurl4-gnutls-dev

#echo "[信息]安装常用工具"
#apt-get install -y net-tools

if [ ${skip_wget_download} != "y" ] ; then
    echo "[信息]开始下载OpenResty..."
    wget https://openresty.org/download/openresty-1.15.8.1.tar.gz
fi

tar -xvf openresty-1.15.8.1.tar.gz
cd openresty-1.15.8.1
echo "[信息]开始编译OpenResty..."
./configure --with-http_v2_module
make && make install

cd ..

if [ ${skip_wget_download} != "y" ] ; then
    echo "[信息]开始下载PHP7.3.6..."
    wget https://www.php.net/distributions/php-7.3.6.tar.gz
fi

tar -xvf php-7.3.6.tar.gz
cd php-7.3.6
echo "[信息]开始编译PHP7.3.6..."
./configure --enable-fpm --with-curl --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-fpm-user=nginx --with-fpm-group=nginx
make && make install

echo "[信息]正在处理PHP环境..."
mv /usr/local/etc/php-fpm.d/www.conf.default /usr/local/etc/php-fpm.d/www.conf
cd /usr/local/etc/
wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/php-fpm.conf


echo "[信息]创建php.ini(生产环境)"
cp /opt/php-7.3.6/php.ini-production /usr/local/lib/
mv /usr/local/lib/php.ini-production /usr/local/lib/php.ini

echo "[信息]正在设置error_log目录"
mkdir /opt/php_errors
chmod 755 /opt/php_errors
echo "#Added by build.sh" >> /usr/local/lib/php.ini
echo "error_log = /opt/php_errors" >> /usr/local/lib/php.ini

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
echo "<?php echo 'Hello world'; ?>" > index.php

if [ ${install_redis} = "y" ] ; then
    echo "[信息]正在安装Redis Server..."
    apt-get install -y redis-server
    echo "[信息]正在处理Redis配置..."
    cd /etc/redis/
    wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/redis.conf -O redis.conf
    service redis-server restart
fi

if [ ${install_swoole} = "y" ] ; then
    echo "[信息]开始安装Swoole扩展..."
    cd /opt
    wget https://github.com/swoole/swoole-src/archive/v4.3.5.tar.gz
    tar -xvf v4.3.5.tar.gz
    cd swoole-src-4.3.5
    phpize
    ./configure
    make && make install

    echo "#Added by build.sh" >> /usr/local/lib/php.ini
    echo "extension=swoole" >> /usr/local/lib/php.ini
fi

if [ ${load_opcache} = "y" ] ; then
    echo "#Added by build.sh" >> /usr/local/lib/php.ini
    echo "zend_extension=opcache" >> /usr/local/lib/php.ini
    echo "[信息]Zend OPcache已写入php.ini配置，请手动参数开启"
fi

if [ ${install_redis_extension} = "y" ] ; then
    echo "[信息]正在下载Redis扩展..."
    cd /opt
    wget https://pecl.php.net/get/redis-4.3.0.tgz
    tar -xvf redis-4.3.0.tgz
    cd redis-4.3.0
    echo "[信息]正在编译Redis扩展..."
    phpize
    ./configure
    make && make install

    echo "[信息]Redis扩展安装完成"

    echo "#Added by build.sh" >> /usr/local/lib/php.ini
    echo "extension=redis" >> /usr/local/lib/php.ini
    echo "[信息]Redis已加入php.ini"
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

#优化内核
echo "[信息]优化Linux内核参数..."
echo "ulimit -n 1024576" >> /etc/security/limits.conf
cd /etc
wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/aliyun/ubuntu/sysctl.conf -O sysctl.conf
chmod 644 sysctl.conf
echo "[信息]内核参数优化完成!"

echo "[信息]配置自动启动..."
cd /etc/init.d
wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/aliyun/ubuntu/start-web-service.sh
chmod 755 start-web-service.sh
update-rc.d start-web-service.sh defaults 90
echo "[信息]自动启动配置完成"

echo "[信息]所有项目均部署完成，建议重启操作系统。"
echo "[信息]网站默认目录为：/opt/www/"

if [ ${install_redis} = "y" ] ; then
    echo "[信息]Redis端口为：16379(已开启UNIX Socket)"
fi
