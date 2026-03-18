#!/bin/bash

# ================================================
# niri-setup: niri 窗口管理器配置
# Shell: fish + MapleMono-NF-CN
# 输入法: fcitx5 + rime 小鹤双拼
# 支持备份/恢复 + --zen-manual 网络波动救援
# ================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
BACKUP_DIR="$HOME/.config/niri-backups"
MAX_BACKUPS=3

# ====================== 命令行参数解析 ======================
SKIP_INSTALL=false
ACTION="install"
MANUAL_ZEN_TAR=""
RESTORE_TIMESTAMP="latest"

while [ $# -gt 0 ]; do
  case "$1" in
    --skip-install)
      SKIP_INSTALL=true
      ;;
    --restore)
      ACTION="restore"
      RESTORE_TIMESTAMP="${2:-latest}"
      [ "$RESTORE_TIMESTAMP" != "latest" ] && shift
      ;;
    --list-backups)
      ACTION="list-backups"
      ;;
    --zen-manual)
      MANUAL_ZEN_TAR="$2"
      shift
      ;;
    --help|-h)
      echo "用法: $0 [选项]"
      echo ""
      echo "选项:"
      echo "  --skip-install          仅部署配置，不安装软件包"
      echo "  --restore [时间戳]      恢复配置（默认恢复最新备份）"
      echo "  --list-backups          列出所有可用备份"
      echo "  --zen-manual PATH       手动指定 Zen Browser tar.xz（网络波动救援）"
      echo "  --help, -h              显示此帮助信息"
      exit 0
      ;;
  esac
  shift
done

# ====================== Zen Browser 函数（移到最前）======================
install_zen_browser() {
    local INSTALL_DIR="$HOME/.local/share/zen-browser"
    local BIN_DIR="$HOME/.local/bin"
    local DESKTOP_DIR="$HOME/.local/share/applications"
    local MANUAL_TAR="${1:-}"
    local TAR_FILE
    local IS_MANUAL=0

    mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$DESKTOP_DIR"

    if [ -n "$MANUAL_TAR" ] && [ -f "$MANUAL_TAR" ]; then
        TAR_FILE="$MANUAL_TAR"
        IS_MANUAL=1
        echo "[INFO] 使用手动下载文件 → $TAR_FILE"
    else
        if [ -n "$MANUAL_TAR" ]; then
            echo "[WARN] 文件不存在：$MANUAL_TAR"
            return 1
        fi

        if [ -x "$BIN_DIR/zen" ]; then
            echo "[INFO] Zen Browser 已安装，跳过"
            return 0
        else
            echo "[INFO] 开始安装 Zen Browser（x86_64）..."
        fi

        TAR_FILE=$(mktemp /tmp/zen.XXXXXX.tar.xz)
        echo "[INFO] 下载最新版..."

        curl -L -f --progress-bar \
            "https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz" \
            -o "$TAR_FILE" || {
            echo "[ERROR] 下载失败！（网络波动/限速）"
            echo ""
            echo "【手动救援步骤】"
            echo "1. 浏览器打开：https://github.com/zen-browser/desktop/releases/latest"
            echo "2. 下载 zen.linux-x86_64.tar.xz"
            echo "3. 保存到任意位置（推荐 ~/Downloads/zen.linux-x86_64.tar.xz）"
            echo "4. 重新执行："
            echo "   $0 --zen-manual ~/Downloads/zen.linux-x86_64.tar.xz"
            echo ""
            rm -f "$TAR_FILE"
            return 1
        }
    fi

    echo "[INFO] 解压并安装..."
    rm -rf "$INSTALL_DIR"/*
    tar -xJf "$TAR_FILE" -C "$INSTALL_DIR" --strip-components=1 || {
        echo "[ERROR] 解压失败！请重新下载。"
        [ "$IS_MANUAL" -eq 0 ] && rm -f "$TAR_FILE"
        return 1
    }
    [ "$IS_MANUAL" -eq 0 ] && rm -f "$TAR_FILE"

    chmod +x "$INSTALL_DIR/zen"
    ln -sf "$INSTALL_DIR/zen" "$BIN_DIR/zen"

    # 桌面集成
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

    echo "[SUCCESS] Zen Browser 安装/升级完成！"
}

# 如果用户传了 --zen-manual，直接执行并退出
if [ -n "$MANUAL_ZEN_TAR" ]; then
    install_zen_browser "$MANUAL_ZEN_TAR"
    exit 0
fi

# ====================== 原有函数（保持不变）======================
echo "🚀 开始配置 niri 环境..."

is_installed() {
  rpm -q "$1" &>/dev/null
}

backup_config() {
  local src="$1"
  local dest_dir="$2"
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_subdir="$BACKUP_DIR/$timestamp"

  mkdir -p "$BACKUP_DIR" "$backup_subdir"

  if [ -f "$dest_dir" ]; then
    cp -p "$dest_dir" "$backup_subdir/$(basename "$dest_dir")"
    echo "  📦 已备份: $dest_dir"
  elif [ -d "$dest_dir" ]; then
    cp -rp "$dest_dir" "$backup_subdir/"
    echo "  📦 已备份目录: $dest_dir"
  fi

  local backups=($(ls -dt "$BACKUP_DIR"/*/ 2>/dev/null))
  if [ ${#backups[@]} -gt $MAX_BACKUPS ]; then
    local to_delete=("${backups[@]:$MAX_BACKUPS}")
    for old_backup in "${to_delete[@]}"; do
      rm -rf "$old_backup"
      echo "  🗑️  删除旧备份: $old_backup"
    done
  fi
}

backup_and_copy() {
  local src="$1"
  local dest="$2"
  local src_is_dir=false
  [ -d "$src" ] && src_is_dir=true

  local actual_dest="$dest"
  if [ -d "$dest" ] && [ "$src_is_dir" = false ]; then
    actual_dest="$dest/$(basename "$src")"
  fi

  [ "$src" -ef "$actual_dest" ] && echo "  ⏭️  跳过（已是同一文件）: $actual_dest" && return 0

  if [ -e "$actual_dest" ]; then
    backup_config "$src" "$actual_dest"
    [ -d "$actual_dest" ] && rm -rf "$actual_dest" || rm -f "$actual_dest"
  fi

  if [ "$src_is_dir" = true ]; then
    mkdir -p "$(dirname "$dest")"
    cp -rp "$src" "$dest"
  else
    mkdir -p "$(dirname "$actual_dest")"
    cp -p "$src" "$actual_dest"
  fi
  echo "  ✅ 已部署: $actual_dest"
}

restore_backup() {
  local timestamp="${1:-latest}"
  if [ "$timestamp" = "latest" ]; then
    local latest=($(ls -dt "$BACKUP_DIR"/*/ 2>/dev/null))
    if [ ${#latest[@]} -eq 0 ]; then
      echo "[ERROR] 没有可用的备份"
      return 1
    fi
    timestamp=$(basename "${latest[0]}")
  fi

  local backup_path="$BACKUP_DIR/$timestamp"
  if [ ! -d "$backup_path" ]; then
    echo "[ERROR] 备份不存在: $timestamp"
    return 1
  fi

  echo "🔄 正在恢复到备份: $timestamp"

  local configs=(
    "$HOME/.config/niri"
    "$HOME/.config/alacritty"
    "$HOME/.config/fcitx5"
    "$HOME/.local/share/fcitx5/rime"
    "$HOME/.config/helix"
    "$HOME/.config/mako"
    "$HOME/.config/waybar"
  )

  for config in "${configs[@]}"; do
    if [ -e "$config" ]; then
      rm -rf "$config"
      echo "  🗑️ 已删除: $config"
    fi
  done

  for item in "$backup_path"/*; do
    if [ -d "$item" ]; then
      local name=$(basename "$item")
      local dest=""
      case "$name" in
        niri) dest="$HOME/.config/niri" ;;
        alacritty) dest="$HOME/.config/alacritty" ;;
        fcitx5) dest="$HOME/.config/fcitx5" ;;
        rime) dest="$HOME/.local/share/fcitx5/rime" ;;
        helix) dest="$HOME/.config/helix" ;;
        mako) dest="$HOME/.config/mako" ;;
        waybar) dest="$HOME/.config/waybar" ;;
      esac
      if [ -n "$dest" ]; then
        cp -rp "$item" "$dest"
        echo "  ✅ 已恢复: $dest"
      fi
    fi
  done

  echo "✅ 恢复完成！请重启 niri 生效"
}

list_backups() {
  echo "📋 可用的备份列表:"
  if [ -d "$BACKUP_DIR" ] && [ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    for backup in $(ls -dt "$BACKUP_DIR"/*/ 2>/dev/null); do
      local name=$(basename "$backup")
      local date=$(echo "$name" | cut -d'_' -f1)
      local time=$(echo "$name" | cut -d'_' -f2)
      echo "  - $name (${date:0:4}-${date:4:2}-${date:6:2} ${time:0:2}:${time:2:2})"
    done
  else
    echo "  (暂无备份)"
  fi
}

# ====================== 新增/优化函数 ======================
add_packsman_if_needed() {
  if ! zypper lr -u | grep -q "packman"; then
    sudo zypper ar -f -p 90 -n "Packman" https://mirrors.aliyun.com/packman/suse/openSUSE_Tumbleweed/ packman
    sudo zypper ref
  fi
}

install_flatpak() {
  if ! command -v flatpak &>/dev/null; then
    echo "[INFO] 安装 Flatpak + Flathub..."
    sudo zypper in -y flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  fi
}

# 安装 DBeaver
install_dbeaver() {
  if ! command -v dbeaver &>/dev/null; then
    echo "[INFO] 安装 DBeaver..."
    curl -L "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm" -o /tmp/dbeaver.rpm
    sudo rpm -ivh /tmp/dbeaver.rpm
    rm -f /tmp/dbeaver.rpm
    echo "[INFO] DBeaver 安装完成"
  fi
}

install_maple_font() {
  local font_dir="$HOME/.local/share/fonts/"
  mkdir -p "$font_dir"
  if [ -z "$(find "$font_dir" -name "*MapleMono*.ttf" 2>/dev/null)" ]; then
    echo "[INFO] 下载 MapleMono-NF-CN 字体..."
    curl -L "https://github.com/subframe7536/maple-font/releases/download/v7.9/MapleMono-NF-CN-unhinted.zip" -o /tmp/MapleMono-NF-CN.zip
    unzip -o /tmp/MapleMono-NF-CN.zip -d "$font_dir"
    rm -f /tmp/MapleMono-NF-CN.zip
    fc-cache -f
    echo "[INFO] MapleMono-NF-CN 字体安装完成"
  else
    echo "[INFO] MapleMono-NF-CN 字体已存在，跳过"
  fi
}

# ====================== ACTION 处理 ======================
if [ "$ACTION" = "restore" ]; then
  restore_backup "$RESTORE_TIMESTAMP"
  exit 0
fi

if [ "$ACTION" = "list-backups" ]; then
  list_backups
  exit 0
fi

# ====================== 安装阶段 ======================
if [ "$SKIP_INSTALL" = false ]; then
  add_packsman_if_needed
  install_flatpak

  # 解除 PackageKit 锁定
  echo "🔓 解除 PackageKit 锁定..."
  sudo systemctl stop packagekit 2>/dev/null || true
  sudo killall -9 packagekitd 2>/dev/null || true
  sleep 2

  # GDM → tuigreet 切换
  echo "🔄 检查并处理显示管理器..."
  if systemctl list-unit-files | grep -q gdm.service || command -v gdm > /dev/null 2>&1; then
      sudo systemctl disable --now gdm.service 2>/dev/null || true
      sudo systemctl mask gdm.service 2>/dev/null || true
      sudo zypper --non-interactive remove -y gdm 2>/dev/null || true
      echo "✅ GDM 已移除"
  fi

  echo "📦 更新系统..."
  sudo zypper --non-interactive refresh
  sudo zypper --non-interactive dup

  # 核心软件包（新增 xdg-desktop-portal + gnome-keyring）
  pkgs=(
    greetd tuigreet niri
    alacritty fuzzel
    brightnessctl cliphist fd figlet mako pamixer power-profiles-daemon polkit-gnome
    swaybg swayidle swaylock swww waybar wlogout xwayland-satellite
    fish eza bat ripgrep zoxide fzf btop dust lazygit atuin
    neovim helix
    python311 python311-pip python311-devel uv
    fcitx5 fcitx5-rime fcitx5-configtool fcitx5-chinese-addons
    openssh-server firewalld
    firefox chromium
    docker virt-manager libvirt qemu-kvm
    libreoffice
    mpv audacious
    ImageMagick git curl unzip

    # niri 必备（新增）
    xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-gnome gnome-keyring
  )
  sudo zypper install -y "${pkgs[@]}"

  # 第三方安装
  install_maple_font
  install_vscode() {
    if ! command -v code &>/dev/null; then
      echo "[INFO] 安装 Visual Studio Code..."
      sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
      sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'
      sudo zypper refresh
      sudo zypper install -y code
    fi
  }
  install_vscode
  install_dbeaver
  install_zen_browser   # ← 自动模式
fi

# ====================== 配置阶段 ======================
config_ssh() {
  if systemctl is-active --quiet sshd.service; then
    echo "[INFO] SSH 服务已启动，跳过"
    return 0
  fi
  echo "🔐 配置 SSH 服务..."
  sudo systemctl enable --now sshd.service
  sudo systemctl enable --now firewalld.service
  sudo firewall-cmd --permanent --add-service=ssh
  sudo firewall-cmd --reload
}

config_greetd() {
  echo "🔧 配置 greetd + tuigreet..."
  sudo tee /etc/greetd/config.toml > /dev/null << 'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --asterisks --remember --remember-session --sessions /usr/share/wayland-sessions/"
user = "greeter"
EOF
  sudo systemctl set-default graphical.target
  sudo systemctl enable --now greetd
}

set_fish_shell() {
  echo "🐟 设置 fish 为默认 shell..."
  if ! grep -q "$(which fish)" /etc/shells 2>/dev/null; then
    echo "$(which fish)" | sudo tee -a /etc/shells
  fi
  sudo chsh -s "$(which fish)" "$USER"
}

config_fish() {
  echo "🐟 配置 fish shell..."
  mkdir -p "$HOME/.config/fish"
  cat > "$HOME/.config/fish/config.fish" << 'EOF'
# niri 环境配置

# Flatpak 支持
set -gx XDG_DATA_DIRS $XDG_DATA_DIRS ~/.local/share/flatpak/exports/share /var/lib/flatpak/exports/share

# 现代工具别名
alias ls='eza --icons --git'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --icons --level=2'
alias cat='bat --paging=never'
alias du='dust'
alias top='btop'
alias grep='rg'
alias find='fd'
alias cd='z'
alias lg='lazygit'

# 初始化现代工具
command -q zoxide; and zoxide init fish | source
command -q atuin;   and atuin init fish | source
command -q fzf;     and fzf --fish | source

# 环境变量
set -x EDITOR nvim
set -x VISUAL nvim
EOF
}

deploy_rime() {
  echo "📝 部署 Rime 小鹤双拼..."
  fcitx5-remote -r 2>/dev/null || true
}

set_default_browser() {
  echo "🌐 设置默认浏览器为 Zen..."
  if command -v xdg-settings &>/dev/null; then
    xdg-settings set default-web-browser zen.desktop 2>/dev/null || true
    xdg-settings set default-url-scheme-handler http zen.desktop 2>/dev/null || true
  fi
}

# ====================== 执行配置 ======================
if [ "$SKIP_INSTALL" = false ]; then
  config_ssh
  config_greetd
  set_fish_shell
  config_fish
  deploy_rime
  set_default_browser
fi

# 配置部署（保持你原来的 backup_and_copy 部分，完全不变）
echo "📁 部署配置文件..."
mkdir -p "$HOME/.config/niri"
for f in "$SCRIPT_DIR"/niri/*.kdl; do
  backup_and_copy "$f" "$HOME/.config/niri/$(basename "$f")"
done

mkdir -p $HOME/.config/alacritty
backup_and_copy "$SCRIPT_DIR/alacritty/default.toml" "$HOME/.config/alacritty/alacritty.toml"
backup_and_copy "$SCRIPT_DIR/alacritty/float.toml" "$HOME/.config/alacritty/"

mkdir -p $HOME/.config/fcitx5
mkdir -p $HOME/.local/share/fcitx5/rime

backup_and_copy "$SCRIPT_DIR/fcitx5/profile" "$HOME/.config/fcitx5/profile"
backup_and_copy "$SCRIPT_DIR/rime/default.custom.yaml" "$HOME/.local/share/fcitx5/rime/default.custom.yaml"
backup_and_copy "$SCRIPT_DIR/rime/double_pinyin_flypy.schema.yaml" "$HOME/.local/share/fcitx5/rime/"

mkdir -p $HOME/.config/helix
for f in "$SCRIPT_DIR"/helix/*.toml; do
  backup_and_copy "$f" "$HOME/.config/helix/$(basename "$f")"
done

mkdir -p $HOME/.config/mako
backup_and_copy "$SCRIPT_DIR/mako/config" "$HOME/.config/mako/config"

mkdir -p $HOME/.config/waybar
for f in "$SCRIPT_DIR"/waybar/*; do
  [ -f "$f" ] && backup_and_copy "$f" "$HOME/.config/waybar/$(basename "$f")"
done

mkdir -p $HOME/.config/wlogout
for f in "$SCRIPT_DIR"/wlogout/*; do
  if [ -f "$f" ]; then
    backup_and_copy "$f" "$HOME/.config/wlogout/$(basename "$f")"
  fi
done
for d in "$SCRIPT_DIR"/wlogout/*/; do
  [ -d "$d" ] && backup_and_copy "$d" "$HOME/.config/wlogout/$(basename "$d")"
done

# Git 配置
backup_and_copy "$SCRIPT_DIR/git/gitconfig" "$HOME/.gitconfig"

echo "✅ 配置部署完成（已自动备份）"
echo "🔧 替换路径占位符..."
sed -i "s|\$NIRICONF|$SCRIPT_DIR|g" "$HOME/.config/niri/wallpapers.kdl" 2>/dev/null || true
sed -i "s|\$NIRICONF|$SCRIPT_DIR|g" "$HOME/.config/niri/binds.kdl" 2>/dev/null || true
sed -i "s|\$NIRICONF|$SCRIPT_DIR|g" "$HOME/.config/niri/spawn-at-startup.kdl" 2>/dev/null || true
sed -i "s|\$NIRICONF|$SCRIPT_DIR|g" "$SCRIPT_DIR/scripts/change-idle-time.sh"
sed -i "s|\$NIRICONF|$SCRIPT_DIR|g" "$SCRIPT_DIR/scripts/change-power-profile.sh"
sed -i "s|\$NIRICONF|$SCRIPT_DIR|g" "$SCRIPT_DIR/scripts/change-wallpaper.sh"
sed -i "s|\$NIRICONF|$SCRIPT_DIR|g" "$SCRIPT_DIR/scripts/swayidle.sh"
sed -i "s|\$NIRICONF|$SCRIPT_DIR|g" "$SCRIPT_DIR/scripts/swaylock.sh"
sed -i "s|\$NIRICONF|$SCRIPT_DIR|g" "$SCRIPT_DIR/scripts/wlogout.sh"
sed -i "s|\$NIRICONF|$SCRIPT_DIR|g" "$HOME/.config/wlogout/layout"

# niri 验证
if niri validate &>/dev/null; then
  echo "[INFO] niri 配置验证通过"
else
  echo "[WARN] 配置有误，请检查："
  niri validate
fi

echo ""
echo "🎉 配置完成！"
echo ""
echo "📋 下一步："
echo "1. 注销或重启电脑"
echo "2. tuigreet 登录后进入 niri"
echo "3. 测试：zen（浏览器）、Super+Space（输入法）"
echo ""
echo "⚠️ 额外操作："
echo "   sudo usermod -aG docker $USER && newgrp docker"
echo "   sudo systemctl enable --now libvirtd"
echo ""
echo "💡 网络波动时安装 Zen：$0 --zen-manual ~/Downloads/zen.linux-x86_64.tar.xz"
