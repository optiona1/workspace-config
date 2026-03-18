#!/bin/bash

set -uo pipefail

install_zen_browser() {
    local INSTALL_DIR="$HOME/.local/share/zen-browser"
    local BIN_DIR="$HOME/.local/bin"
    local DESKTOP_DIR="$HOME/.local/share/applications"

    mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$DESKTOP_DIR"

    if [ -x "$BIN_DIR/zen" ]; then
        echo "[INFO] Zen Browser 已安装，跳过"
        return 0
    fi

    echo "[INFO] 开始安装 Zen Browser（x86_64）..."
    local TAR_FILE=$(mktemp /tmp/zen.XXXXXX.tar.xz)
    echo "[INFO] 下载最新版..."

    if ! curl -L -f --progress-bar \
        "https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz" \
        -o "$TAR_FILE"; then
        echo "[WARN] 下载失败，跳过安装"
        rm -f "$TAR_FILE"
        return 0
    fi

    echo "[INFO] 解压并安装..."
    rm -rf "$INSTALL_DIR"/*
    if ! tar -xJf "$TAR_FILE" -C "$INSTALL_DIR" --strip-components=1; then
        echo "[WARN] 解压失败，跳过安装"
        rm -f "$TAR_FILE"
        return 0
    fi
    rm -f "$TAR_FILE"

    chmod +x "$INSTALL_DIR/zen"
    ln -sf "$INSTALL_DIR/zen" "$BIN_DIR/zen"

    if [ -f "$INSTALL_DIR/zen.desktop" ]; then
        cp "$INSTALL_DIR/zen.desktop" "$DESKTOP_DIR/zen.desktop"
        sed -i "s|^Exec=.*|Exec=$BIN_DIR/zen %u|" "$DESKTOP_DIR/zen.desktop"
        update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
    else
        cat > "$DESKTOP_DIR/zen.desktop" << DESKTOP_EOF
[Desktop Entry]
Encoding=UTF-8
Name=Zen
GenericName=Web Browser
Comment=Browse the Web
TryExec=${BIN_DIR}/zen
Exec=${BIN_DIR}/zen %u
Icon=zen
Terminal=false
StartupNotify=true
Categories=Network;WebBrowser;GTK;
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;application/x-xpinstall;x-scheme-handler/http;x-scheme-handler/https;
Type=Application

Actions=new-window;PrivateBrowsing;ProfileManager

[Desktop Action new-window]
Name=New Window
Name[zh_CN]=新建窗口
Exec=${BIN_DIR}/zen --new-window %u

[Desktop Action PrivateBrowsing]
Name=New Private Browsing Window
Name[zh_CN]=新建隐私浏览窗口
Exec=${BIN_DIR}/zen --private-window %u

[Desktop Action ProfileManager]
Name=Profile Manager
Exec=${BIN_DIR}/zen --ProfileManager
DESKTOP_EOF
        echo "[INFO] 手动创建 desktop 文件"
    fi

    if [ -f "$INSTALL_DIR/browser/chrome/icons/default/default128.png" ]; then
        mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"
        cp "$INSTALL_DIR/browser/chrome/icons/default/default128.png" "$HOME/.local/share/icons/hicolor/256x256/apps/zen.png"
    fi

    echo "[SUCCESS] Zen Browser 安装完成！"
}

install_zen_browser
