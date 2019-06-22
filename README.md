# Docker 一键部署OpenResty、PHP、Redis Server
#### 安装命令
`apt-get update;apt-get install -y wget;wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/build.sh;chmod 777 build.sh;./build.sh`

##### 运行环境：`Ubuntu 16.04`
- OpenResty版本：`1.15.8.1`
- PHP版本：`7.3.6`
------------
PHP包含的扩展
- Swoole( v4.3.5 )
- Redis( v4.3.0 )
- cURL
- MySQL

##### 请使用全新环境安装
- 网站默认根目录：`/opt/www/`
- Redis端口：`16379`
