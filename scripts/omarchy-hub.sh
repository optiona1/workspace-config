#!/bin/bash

set -euo pipefail

MENU_CONFIG="$NIRICONF/fuzzel/omarchy.ini"

pick() {
  printf '%b' "$1" | fuzzel --dmenu --config "$MENU_CONFIG"
}

notify() {
  local title="$1"
  local body="$2"
  notify-send "$title" "$body" -a "Omarchy Hub"
}

run_install() {
  local label="$1"
  local cmd="$2"

  alacritty --title "Omarchy Install - $label" --config-file "$NIRICONF/alacritty/float.toml" -e bash -lc "$cmd; echo; read -n 1 -s -r -p '按任意键退出...'"
}

main_menu=$(pick "󰖟 Omarchy Hub\n Launch Apps\n󰏖 Install Packs\n󰔛 System Actions")

case "$main_menu" in
" Launch Apps")
  app=$(pick " Terminal\n󰈹 Browser\n Files\n󰨞 Editor\n󰎈 Music")
  case "$app" in
    " Terminal") alacritty ;;
    "󰈹 Browser") zen || chromium ;;
    " Files") nautilus ;;
    "󰨞 Editor") code || helix ;;
    "󰎈 Music") audacious ;;
  esac
  ;;
"󰏖 Install Packs")
  pack=$(pick "󰛳 Dev Base\n󰕧 Media Kit\n󱓞 AI Local")
  case "$pack" in
    "󰛳 Dev Base")
      run_install "Dev Base" "sudo zypper install -y git git-lfs lazygit tmux direnv podman podman-compose"
      ;;
    "󰕧 Media Kit")
      run_install "Media Kit" "sudo zypper install -y vlc obs-studio ffmpegthumbnailer"
      ;;
    "󱓞 AI Local")
      run_install "AI Local" "sudo zypper install -y ollama python311-pipx && sudo systemctl enable --now ollama"
      ;;
  esac
  ;;
"󰔛 System Actions")
  action=$(pick "󰑐 Reload Niri\n󰍃 Lock\n󰤄 Sleep\n󰜉 Reboot\n Power Off")
  case "$action" in
    "󰑐 Reload Niri") niri msg action reload ; notify "Niri" "配置已重新加载" ;;
    "󰍃 Lock") "$NIRICONF/scripts/swaylock.sh" ;;
    "󰤄 Sleep") systemctl suspend ;;
    "󰜉 Reboot") systemctl reboot ;;
    " Power Off") systemctl poweroff ;;
  esac
  ;;
esac
