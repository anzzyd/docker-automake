# Aliyun ECS 一键部署Web集群
#### 一键上线命令
`apt-get update;apt-get install -y wget;wget https://raw.githubusercontent.com/anzzyd/docker-automake/master/build.sh;chmod 777 build.sh;./build.sh`

##### 适用环境：`Ubuntu 16.04`
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

### 更新日志

##### v2.9.7.16
- 新增master.ip，用于内部解析
- 调整start-web-service.sh解析为master.ip
- start-master.sh 新增启动项 cyd_backend_server / cyd_udplogserver

##### v2.8.7.9
- 调整php.ini的时区为PRC
- 新增开机日志
- nginx.conf改为从OSS中拉取

##### v2.7.7.5
- 修复开机无法拉取项目文件的Bug
- 修复开机无法启动探针的Bug

##### v2.6.7.5
- 新增探针功能，上报服务器信息至Master