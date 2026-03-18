#!/bin/bash

set -uo pipefail

install_maple_font() {
    local font_dir="$HOME/.local/share/fonts/"
    mkdir -p "$font_dir"

    if [ -n "$(find "$font_dir" -name "*MapleMono*.ttf" 2>/dev/null)" ]; then
        echo "[INFO] MapleMono-NF-CN 字体已存在，跳过"
        return 0
    fi

    echo "[INFO] 下载 MapleMono-NF-CN 字体..."
    if ! curl -L "https://github.com/subframe7536/maple-font/releases/download/v7.9/MapleMono-NF-CN-unhinted.zip" -o /tmp/MapleMono-NF-CN.zip; then
        echo "[WARN] 字体下载失败，跳过安装"
        return 0
    fi
    unzip -o /tmp/MapleMono-NF-CN.zip -d "$font_dir" || true
    rm -f /tmp/MapleMono-NF-CN.zip
    fc-cache -f || true
    echo "[INFO] MapleMono-NF-CN 字体安装完成"
}

install_maple_font