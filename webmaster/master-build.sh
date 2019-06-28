#!/bin/bash

echo -e "\033[32m\033[1m【警告】请确保在全新环境中执行该脚本，是否继续？\033[0m"
stty erase '^H' && read -p "(默认: n):" start_build
if [ ${start_build} != "y" ] ; then
    exit
fi

echo -e "\033[32m\033[1m【信息】开始配置CYD-WebMaster服务器\033[0m"

apt-get update
apt-get install -y vim
apt-get install -y wget
apt-get install -y rsync
apt-get install -y inotify-tools

# 配置密码
echo -e "\033[32m\033[1m【信息】配置Rsync密码...\033[0m"
echo 6wfOm5uTi2ZY2NFn > /etc/rsyncd.password
chmod 600 /etc/rsyncd.password

# 配置推送服务器（用于新ecs拉取项目文件）

echo -e "\033[32m\033[1m【信息】创建www目录\033[0m"
mkdir /opt/www

echo -e "\033[32m\033[1m【信息】拉取master rsyncd.conf...\033[0m"
cd /etc
wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/webmaster/rsyncd.conf -O rsyncd.conf

echo -e "\033[32m\033[1m【信息】关闭rsync server...\033[0m"
PROCESS=`ps -ef|grep rsync|grep -v grep|grep -v PPID|awk '{ print $2}'`
for i in $PROCESS
do
    kill $i
done

rm /var/run/rsyncd.pid
echo -e "\033[32m\033[1m【信息】启动rsync server...\033[0m"
rsync --daemon

echo -e "\033[32m\033[1m【信息】拉取sender.sh监听脚本...\033[0m"
cd /opt
wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/webmaster/sender.sh -O sender.sh
chmod 777 sender.sh
echo -e "\033[32m\033[1m【信息】拉取sender.sh成功，请手动启动!\033[0m"

echo -e "\033[32m\033[1m【信息】正在配置开机启动...\033[0m"
cd /etc/init.d
wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/webmaster/start-master.sh -O start-master.sh
chmod 755 start-master.sh
update-rc.d start-master.sh defaults 90
echo -e "\033[34m\033[1m【信息】开机启动配置完成\033[0m"

