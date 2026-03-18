#!/bin/bash

set -uo pipefail

install_vscode() {
    if command -v code &>/dev/null; then
        echo "[INFO] VSCode 已安装，跳过"
        return 0
    fi

    echo "[INFO] 安装 Visual Studio Code..."
    if ! sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc 2>/dev/null; then
        echo "[WARN] GPG 密钥导入失败，跳过"
        return 0
    fi
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo' || true
    sudo zypper refresh 2>/dev/null || true
    sudo zypper install -y code || {
        echo "[WARN] VSCode 安装失败，跳过"
        return 0
    }
    echo "[INFO] VSCode 安装完成"
}

install_vscode