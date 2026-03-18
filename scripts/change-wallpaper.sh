#!/bin/bash

# 壁纸目录
wallpaper_dir="$HOME/Pictures/Wallpapers"

# 如果目录不存在则创建
if [ ! -d "$wallpaper_dir" ]; then
  mkdir -p "$wallpaper_dir"
fi

# 获取可用壁纸列表
images=$(fd . --base-directory "$wallpaper_dir" | grep -e ".jpg" -e ".png" | sort)

# 检查是否有壁纸可用
if [ -z "$images" ]; then
  echo "[ERROR] 未找到图片文件"
  echo "[INFO] 请将壁纸放置在 $wallpaper_dir"
  read -n 1 -s -r -p "[INFO] 按任意键结束..."
  exit 1
fi

# 使用 fzf 选择壁纸
image="$wallpaper_dir/$(echo "$images" | fzf --header '选择壁纸: ')"
if [ $? -eq 1 ]; then
  exit 1
fi

# 选择壁纸显示模式
mode=$(echo -e "stretch\nfill\nfit\ncenter\ntile" | fzf --header "选择显示模式: ")
if [ $? -eq 1 ]; then
  exit 1
fi

# 更新工作区壁纸
echo "[INFO] 新壁纸: $image"
echo "[INFO] 复制壁纸到 $NIRICONF..."
cp -f $image "$NIRICONF/wallpapers/workspace.${image##*.}"

# 提取图片主色调用于 swaybg 背景色
canvas_color=$(magick $NIRICONF/wallpapers/workspace.${image##*.} -crop x1+0+0 -resize 1x1 txt:- | grep -o '#[0-9A-Fa-f]\{6\}')
workspace_cmd="swaybg -i $NIRICONF/wallpapers/workspace.${image##*.} -m $mode -c '$canvas_color'"

# 更新 niri 配置并重启 swaybg
sed -i "s|^spawn-sh-at-startup \"swaybg.*|spawn-sh-at-startup \"$workspace_cmd\"|" "$NIRICONF/niri/config.kdl"
pkill swaybg
nohup sh -c "$workspace_cmd" >/dev/null 2>&1 &

# 创建 overview 模糊背景
echo "[INFO] 正在创建 overview 背景..."
magick "$NIRICONF/wallpapers/workspace.${image##*.}" -scale 10% -blur 0x2.5 -resize 1000% "$NIRICONF/wallpapers/backdrop.${image##*.}"
backdrop_cmd="swww-daemon \& swww img $NIRICONF/wallpapers/backdrop.${image##*.}"
swww img "$NIRICONF/wallpapers/backdrop.${image##*.}"
sed -i "s|^spawn-sh-at-startup \"swww.*img.*|spawn-sh-at-startup \"$backdrop_cmd\"|" "$NIRICONF/niri/config.kdl"

echo "[INFO] 完成!"
read -n 1 -s -r -p "[INFO] 按任意键结束..."
