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

echo "Cloudreve配置文件生成完毕"

cat > /cloudreve/aria2.conf <<-EOF
## 文件保存相关 ##
 
# 文件保存目录
dir=/cloudreve/aria2
# 启用磁盘缓存, 0为禁用缓存, 需1.16以上版本, 默认:16M
disk-cache=32M
# 断点续传
continue=true
 
# 文件预分配方式, 能有效降低磁盘碎片, 默认:prealloc
# 预分配所需时间: none < falloc ? trunc < prealloc
# falloc和trunc则需要文件系统和内核支持
# NTFS建议使用falloc, EXT3/4建议trunc, MAC 下需要注释此项
file-allocation=trunc
 
## 下载连接相关 ##
 
# 最大同时下载任务数, 运行时可修改, 默认:5
max-concurrent-downloads=6
# 同一服务器连接数, 添加时可指定, 默认:1
# 官方的aria2最高设置为16, 如果需要设置任意数值请重新编译aria2
max-connection-per-server=16
# 整体下载速度限制, 运行时可修改, 默认:0（不限制）
#max-overall-download-limit=0
# 单个任务下载速度限制, 默认:0（不限制）
#max-download-limit=0
# 整体上传速度限制, 运行时可修改, 默认:0（不限制）
#max-overall-upload-limit=0
# 单个任务上传速度限制, 默认:0（不限制）
#max-upload-limit=0
# 禁用IPv6, 默认:false
# disable-ipv6=true
 
# 最小文件分片大小, 添加时可指定, 取值范围1M -1024M, 默认:20M
# 假定size=10M, 文件为20MiB 则使用两个来源下载; 文件为15MiB 则使用一个来源下载
min-split-size=10M
# 单个任务最大线程数, 添加时可指定, 默认:5
# 建议同max-connection-per-server设置为相同值
split=16
 
## 进度保存相关 ##
 
# 从会话文件中读取下载任务
input-file=/cloudreve/aria2.session
# 在Aria2退出时保存错误的、未完成的下载任务到会话文件
save-session=/cloudreve/aria2.session
# 定时保存会话, 0为退出时才保存, 需1.16.1以上版本, 默认:0
save-session-interval=0
 
## RPC相关设置 ##
 
# 启用RPC, 默认:false
enable-rpc=true
# 允许所有来源, 默认:false
rpc-allow-origin-all=true
# 允许外部访问, 默认:false
rpc-listen-all=true
# RPC端口, 仅当默认端口被占用时修改
# rpc-listen-port=6800
# 设置的RPC授权令牌, v1.18.4新增功能, 取代 --rpc-user 和 --rpc-passwd 选项
rpc-secret=aria2password
# 启动SSL
# rpc-secure=true
# 证书文件, 如果启用SSL则需要配置证书文件, 例如用https连接aria2
# rpc-certificate=
# rpc-private-key=
 
## BT/PT下载相关 ##
 
# 当下载的是一个种子(以.torrent结尾)时, 自动开始BT任务, 默认:true
follow-torrent=true
# 客户端伪装, PT需要
peer-id-prefix=-TR2770-
user-agent=Transmission/2.77
# 强制保存会话, 即使任务已经完成, 默认:false
# 较新的版本开启后会在任务完成后依然保留.aria2文件
#force-save=false
# 继续之前的BT任务时, 无需再次校验, 默认:false
bt-seed-unverified=true
# 保存磁力链接元数据为种子文件(.torrent文件), 默认:false
# bt-save-metadata=true
# 单个种子最大连接数, 默认:55 0表示不限制
bt-max-peers=0
# 最小做种时间, 单位:分
# seed-time = 60
# 分离做种任务
bt-detach-seed-only=true
# 禁止做种
seed-time=0
EOF

echo "Aria2配置文件生成完毕"

echo "准备运行Aria2"

aria2c --conf-path=/cloudreve/aria2.conf -D

echo "准备运行Cloudreve"

chmod +x /cloudreve/cloudreve

cd /cloudreve

./cloudreve
