#!/bin/bash

# 等待屏幕过渡动画完成
niri msg action do-screen-transition --delay-ms 300

# 启动 swaylock 锁屏

IMG="$NIRICONF/wallpapers/backdrop.jpg"

# 截图
#grim "$IMG"

# 模糊（用 ImageMagick）
magick "$IMG" -blur 0x8 "$IMG"

# 启动锁屏
swaylock \
  --daemonize \
  --ignore-empty-password \
  --image "$IMG" \
  --scaling fill \
  --indicator-idle-visible \
  --indicator-radius 100 \
  --indicator-thickness 7 \
  --ring-color 61768ff2 \
  --key-hl-color 61768ff2 \
  --text-color ffffffe6 \
  --inside-color 0b0b0cf2
