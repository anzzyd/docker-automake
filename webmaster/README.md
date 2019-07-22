# 构建Master步骤

##### Build：
`apt-get update;apt-get install -y wget;wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/webmaster/master-build.sh;chmod 777 master-build.sh;./master-build.sh`

##### 相关项：
- apt install mysql-server
-- vim /etc/mysql/mysql.conf.d/mysqld.cnf
-- bind-address 0.0.0.0 & skip-grant-tables
-- Create DB cluster charset utf8 / utf8-general-ci
-- Recovery
- apt install php7.0-cli
- apt install php7.0-dev
- Swoole extension
-- phpize
-- ./configure
-- make && make install
- Configure master backend api server
- Configure UDPLog server
- Configure hosts master.ip