#!/bin/bash

# 启动监听，修改自动推送到web集群
src=/opt/www/
des=cydengine
rsync_passwd_file=/etc/rsyncd-send.password
iplist=("172.17.210.142" "172.17.210.143")
user=rsync_www
cd ${src}
/usr/bin/inotifywait -mrq --format  '%Xe %w%f' -e modify,create,delete,attrib,close_write,move ./ | while read file

do
    INO_EVENT=$(echo $file | awk '{print $1}')
    INO_FILE=$(echo $file | awk '{print $2}')

    if [[ $INO_EVENT =~ 'CREATE' ]] || [[ $INO_EVENT =~ 'MODIFY' ]] || [[ $INO_EVENT =~ 'CLOSE_WRITE' ]] || [[ $INO_EVENT =~ 'MOVED_TO' ]]
    then
        for ip in ${iplist[@]};do
            rsync -rlptDqzcR --contimeout=10 --password-file=${rsync_passwd_file} $(dirname ${file}) ${user}@${ip}::${des}
        done
    fi

    if [[ $INO_EVENT =~ 'DELETE' ]] || [[ $INO_EVENT =~ 'MOVED_FROM' ]]
    then
        for ip in ${iplist[@]};do
            rsync -rzR --delete --contimeout=10 --password-file=${rsync_passwd_file} $(dirname ${file}) ${user}@${ip}::${des}
        done
    fi

    if [[ $INO_EVENT =~ 'ATTRIB' ]]
    then
        if [ ! -d "$INO_FILE" ]
        then
            for ip in ${iplist[@]};do
                rsync -rlptDqzcR --contimeout=10 --password-file=${rsync_passwd_file} $(dirname ${file}) ${user}@${ip}::${des}
            done
        fi
    fi
done