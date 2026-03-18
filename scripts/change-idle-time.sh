#!/bin/bash

# 可用的空闲时间选项
modes="5 minutes\n10 minutes\n20 minutes\n30 minutes\ninfinity"

# 使用 fuzzel 选择空闲时间
choice=$(echo -e "$modes" | fuzzel --dmenu --lines 5 -w 20 --config $NIRICONF/fuzzel/idle-time.ini)

# 如果选择了选项，更新配置并重启 swayidle
if [ ! -z "$choice" ]; then
  pkill swayidle
  echo $choice >$HOME/.local/state/idle-time
  bash $NIRICONF/scripts/swayidle.sh &
  disown
fi
