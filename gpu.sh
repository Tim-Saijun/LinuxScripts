#!/bin/bash
# 需要安装rc: apt-get install bc
THRESHOLD_GPU_UTI=60

# 初始化标志为0
flag=0
while true; do
    # 获取GPU利用率和显存使用情况
    GPU_INFO=$(nvidia-smi -i 0 --query-gpu=memory.used,memory.total,utilization.gpu --format=csv,noheader,nounits)
    GPU_UTIL=$(echo $GPU_INFO | awk -F ', ' '{print $3}')
    GPU_MEM_USED=$(echo $GPU_INFO | awk -F ', ' '{print $1}')
    GPU_MEM_TOTAL=$(echo $GPU_INFO | awk -F ', ' '{print $2}')

    # 判断GPU利用率是否低于THRESHOLD_GPU_UTI
    if (( $(echo "$GPU_UTIL < $THRESHOLD_GPU_UTI" | bc -l) )) && (( $(echo "$GPU_MEM_USED < 8192" | bc -l) )); then
        # 如果GPU利用率低于THRESHOLD_GPU_UTI，并且之前利用率是大于THRESHOLD_GPU_UTI，则通过Webhook发送包含显存使用情况的消息
        if [ $flag -eq 1 ]; then
            curl -H 'Content-type: application/json' -d "{\"msgtype\": \"text\",\"text\":{\"content\":\"$HOST_NAME的GPU占用率为$GPU_UTIL%.😄$GPU_MEM_USED MB/ $GPU_MEM_TOTAL MB.\"}}" $URL_GPU
            # 更新标志为0
            flag=0
        fi
    else
        # 如果GPU利用率大于THRESHOLD_GPU_UTI，并且之前利用率是小于THRESHOLD_GPU_UTI，则通过Webhook发送包含显存使用情况的消息
        if [ $flag -eq 0 ]; then
            curl -H 'Content-type: application/json' -d "{\"msgtype\": \"text\",\"text\":{\"content\":\"$HOST_NAME的GPU占用率为$GPU_UTIL%.😢$GPU_MEM_USED MB/ $GPU_MEM_TOTAL MB.\"}}" $URL_GPU
            # 更新标志为1
            flag=1
        fi
    fi

    # 每隔一分钟检查一次
    sleep 60
done