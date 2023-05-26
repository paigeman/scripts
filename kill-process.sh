#!/bin/bash

# 获取传递的进程名称或关键字作为命令行参数
process_name="$1"

if [ -z "$process_name" ]; then
  echo "请输入要查找的进程名称或关键字。"
  exit 1
fi

# 使用 pgrep 命令获取匹配进程名称或关键字的进程 ID
pids=$(pgrep -f "$process_name")

if [ -n "$pids" ]; then
  # 循环遍历进程 ID，发送终止信号给每个进程
  for pid in $pids; do
    kill "$pid"
    echo "进程 $pid 已关闭。"
  done
else
  echo "未找到进程 $process_name。"
fi
