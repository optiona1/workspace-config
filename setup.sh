#!/bin/bash

# ================================================
# niri-setup: niri 窗口管理器配置
# Shell: fish + MapleMono-NF-CN
# 输入法: fcitx5 + rime 小鹤双拼
# 支持备份/恢复
# ================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
BACKUP_DIR="$HOME/.config/niri-backups"
MAX_BACKUPS=3

# ====================== 命令行参数解析 ======================
SKIP_INSTALL=false
ACTION="install"
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
    --help|-h)
      echo "用法: $0 [选项]"
      echo ""
      echo "选项:"
      echo "  --skip-install          仅部署配置，不安装软件包"
      echo "  --restore [时间戳]      恢复配置（默认恢复最新备份）"
      echo "  --list-backups          列出所有可用备份"
      echo "  --help, -h              显示此帮助信息"
      exit 0
      ;;
  esac
  shift
done

# ====================== 第三方软件安装 ======================
install_third_party_software() {
    echo "📦 安装第三方软件（失败不影响主流程）..."
    
    bash "$SCRIPT_DIR/scripts/install-maple-font.sh" || echo "[WARN] Maple 字体安装失败，跳过"
    bash "$SCRIPT_DIR/scripts/install-vscode.sh" || echo "[WARN] VSCode 安装失败，跳过"
    bash "$SCRIPT_DIR/scripts/install-dbeaver.sh" || echo "[WARN] DBeaver 安装失败，跳过"
    bash "$SCRIPT_DIR/scripts/install-zen-browser.sh" || echo "[WARN] Zen Browser 安装失败，跳过"
    
    echo "✅ 第三方软件安装完成"
}

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
    docker jq virt-manager libvirt qemu-kvm
    nautilus
    libreoffice
    mpv audacious
    ImageMagick git curl unzip

    # niri 必备（新增）
    xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-gnome gnome-keyring
  )

  # uv 镜像加速配置
  echo "📦 配置 uv 镜像加速..."
  UV_CONFIG_DIR="$HOME/.config/uv"
  UV_CONFIG_FILE="$UV_CONFIG_DIR/uv.toml"
  mkdir -p "$UV_CONFIG_DIR"

  if [ -f "$UV_CONFIG_FILE" ]; then
    if grep -q 'pypi.tuna.tsinghua.edu.cn' "$UV_CONFIG_FILE" 2>/dev/null; then
      echo "  [INFO] uv 镜像已配置，跳过"
    else
      echo "  [INFO] 检测到现有配置，追加镜像..."
      cat >> "$UV_CONFIG_FILE" << 'EOF'

[[index]]
url = "https://pypi.tuna.tsinghua.edu.cn/simple"
explicit = true

[[index]]
url = "https://mirrors.aliyun.com/pypi/simple"
explicit = true
EOF
      echo "  ✅ 已追加 uv 镜像配置"
    fi
  else
    cat > "$UV_CONFIG_FILE" << 'EOF'
[[index]]
url = "https://pypi.tuna.tsinghua.edu.cn/simple"
explicit = true

[[index]]
url = "https://mirrors.aliyun.com/pypi/simple"
explicit = true
EOF
    echo "  ✅ 已创建 uv 镜像配置"
  fi

  sudo zypper install -y "${pkgs[@]}"

  # Docker 组配置
  echo "👤 将当前用户加入 docker 组..."
  sudo usermod -aG docker "$USER"
  echo "[INFO] 已将 $USER 加入 docker 组（需要重新登录生效）"

  # Docker 镜像加速配置
  echo "🐳 配置 Docker 镜像加速..."
  DOCKER_DAEMON="/etc/docker/daemon.json"
  DOCKER_MIRRORS='"registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.1msyun.com",
    "https://pull.1ms.run",
    "https://mirror.gcr.io",
    "https://registry.docker-cn.com"
  ]'

  if [ -f "$DOCKER_DAEMON" ]; then
    if grep -q 'registry-mirrors' "$DOCKER_DAEMON"; then
      echo "  [INFO] 镜像加速已配置，跳过"
    else
      echo "  [INFO] 检测到现有配置，追加镜像加速..."
      sudo cp "$DOCKER_DAEMON" "$DOCKER_DAEMON.bak"
      local temp_file=$(mktemp)
      jq -s '.[0] * {"registry-mirrors": .[1]}' "$DOCKER_DAEMON" \
        "$(echo "$DOCKER_MIRRORS" | jq '.')" > "$temp_file"
      sudo mv "$temp_file" "$DOCKER_DAEMON"
      echo "  ✅ 已追加镜像加速配置"
    fi
  else
    echo "  [INFO] 创建 Docker 配置文件..."
    sudo tee "$DOCKER_DAEMON" > /dev/null << EOF
{
  $DOCKER_MIRRORS,
  "builder": {
    "gc": {
      "enabled": true,
      "defaultKeepStorage": "20GB"
    }
  },
  "experimental": false,
  "features": {
    "buildkit": true
  }
}
EOF
    echo "  ✅ 已创建 Docker 镜像加速配置"
  fi
  sudo systemctl daemon-reload
  sudo systemctl restart docker

  # 第三方安装
  install_third_party_software
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
  sudo systemctl enable greetd
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
sed -i "s|\$NIRICONF|$SCRIPT_DIR|g" "$SCRIPT_DIR/scripts/omarchy-hub.sh"
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
echo "   sudo systemctl enable --now libvirtd"

# 启动 greetd
echo "🚀 启动 greetd 登录管理器..."
sudo systemctl enable --now greetd
