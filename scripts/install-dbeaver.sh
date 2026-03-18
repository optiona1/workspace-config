#!/bin/bash

set -uo pipefail

install_dbeaver() {
    if command -v dbeaver &>/dev/null; then
        echo "[INFO] DBeaver 已安装，跳过"
        return 0
    fi

    echo "[INFO] 安装 DBeaver..."
    if ! curl -L "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm" -o /tmp/dbeaver.rpm; then
        echo "[WARN] DBeaver 下载失败，跳过安装"
        return 0
    fi
    sudo rpm -ivh /tmp/dbeaver.rpm || {
        echo "[WARN] DBeaver 安装失败，跳过"
        rm -f /tmp/dbeaver.rpm
        return 0
    }
    rm -f /tmp/dbeaver.rpm
    echo "[INFO] DBeaver 安装完成"
}

install_dbeaver