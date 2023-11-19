#!/bin/bash

DATE="$(date "+%Y-%m-%d %H:%M")"
NAME=$HOST_NAME
# 获取登录用户的信息
USER_INFO=$(whoami)

# 获取登录IP
IP_INFO=$(echo $SSH_CONNECTION | cut -d " " -f 1)

# 创建要发送的消息
MESSAGE="$NAME:$USER_INFO 从IP $IP_INFO 登录了💡[$DATE]"

# 使用curl发送webhook请求
curl -s -H 'Content-type: application/json' -d "{\"msgtype\": \"text\",\"text\":{\"content\":\"$MESSAGE.\"}}" $URL_SSH > ~/sshlog
echo $MESSAGE > ~/sshlog