#!/bin/bash

# 启动 wlogout 注销菜单
# -C: 指定样式文件
# -l: 指定布局文件
# -b: 按钮数量
# -T/-B: 上下边距
wlogout -C $NIRICONF/wlogout/style.css -l $NIRICONF/wlogout/layout -b 5 -T 400 -B 400
