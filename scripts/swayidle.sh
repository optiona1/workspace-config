#!/bin/bash

# 锁屏脚本路径
lock="$NIRICONF/scripts/swaylock.sh"

# 如果空闲时间配置文件不存在，使用默认值
if [ ! -f $HOME/.local/state/idle-time ]; then
  echo "10 minutes" >$HOME/.local/state/idle-time
fi

# 读取空闲时间配置
idle_time=$(cat $HOME/.local/state/idle-time)

# 根据配置启动 swayidle
case $idle_time in
  "5 minutes")
    swayidle -w \
      timeout 300 $lock \
      timeout 420 'niri msg action power-off-monitors' \
      timeout 1800 'systemctl suspend' \
      before-sleep $lock
    ;;
  "10 minutes")
    swayidle -w \
      timeout 600 $lock \
      timeout 720 'niri msg action power-off-monitors' \
      timeout 1800 'systemctl suspend' \
      before-sleep $lock
    ;;
  "20 minutes")
    swayidle -w \
      timeout 1200 $lock \
      timeout 1500 'niri msg action power-off-monitors' \
      timeout 2400 'systemctl suspend' \
      before-sleep $lock
    ;;
  "30 minutes")
    swayidle -w \
      timeout 1800 $lock \
      timeout 2100 'niri msg action power-off-monitors' \
      timeout 3600 'systemctl suspend' \
      before-sleep $lock
    ;;
  "infinity") ;;
  *) ;;
esac
