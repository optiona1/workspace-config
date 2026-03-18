#!/bin/bash

# 电源模式选项
options="power-saver\nbalanced\nperformance"

# 使用 fuzzel 选择电源模式
choice=$(echo -e "$options" | fuzzel --dmenu --lines 3 -w 20 --config $NIRICONF/fuzzel/power-profile.ini)

# 如果选择了选项，应用电源模式
if [ ! -z "$choice" ]; then
  powerprofilesctl set $choice
fi
