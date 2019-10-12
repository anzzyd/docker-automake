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

##### v3.5.10.12
- PHP编译参数新增 enable-mbstring
- 新增example配置样例

##### v3.4.8.16
- 新增安装subversion
- 新增内部域名解析svn.ip

 ###### 禁用rsync服务(如需恢复取消注释即可)
 1. start-web-service.sh禁用rsync服务启动和项目拉取功能
 2. start-master.sh禁用rsync服务和sender.sh脚本
 3. build.sh禁用rsync相关（185\192\193\194）行

##### v3.3.8.1
- 新增部署时安装http.lua和http_headers.lua扩展

##### v3.2.7.31
- OpenResty增加--with-http_stub_status_module编译选项
- 增加登录执行脚本sshrc
- 移除build.sh中的测试结果代码
- 新增部署时默认安装Redis server

##### v3.1.7.22
- 修复/opt/php_errors/log.txt权限归属为nginx，防止新上线机器无法记录PHP日志

##### v3.0.7.22
- 修复start-master.sh启动sender.sh后不会启动backend api server以及udplog server的问题
- 优化build.sh下载redis & swoole扩展，下载前先判断文件是否存在，存在则跳过

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