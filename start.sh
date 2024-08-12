#!/bin/bash

chmod -R 777 /cloudreve

echo "目录权限设置完毕"

cat > /cloudreve/conf.ini <<-EOF
[System]
Mode = slave
Listen = :5212

[Slave]
Secret = $SECRET

; 以下为可选的设置，对应主机节点的相关参数，可以通过配置文件应用到从机节点，请根据
; 实际情况调整。更改下面设置需要重启从机节点后生效。
[OptionOverwrite]
; 任务队列最多并行执行的任务数
max_worker_num = 6
; 任务队列中转任务传输时，最大并行协程数
max_parallel_transfer = 6
; 中转分片上传失败后重试的最大次数
chunk_retries = 6
EOF

echo "配置文件生成完毕"

chmod +x /cloudreve/cloudreve

echo "准备运行Cloudreve"

./cloudreve
