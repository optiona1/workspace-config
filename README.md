# workspace-config

基于 [niri](https://github.com/YaLTeR/niri) 的 Wayland 窗口管理器配置，专为 openSUSE Tumbleweed 设计。

## 组件

- **窗口管理器** [niri](https://github.com/YaLTeR/niri)
- **启动器** [Fuzzel](https://codeberg.org/dnkl/fuzzel)
- **状态栏** [Waybar](https://github.com/Alexays/Waybar)
- **字体** [MapleMono NF CN](https://github.com/subframe7536/maple-font)
- **通知** [mako](https://github.com/emersion/mako)
- **剪贴板** [cliphist](https://github.com/sentriz/cliphist)
- **壁纸** [swaybg](https://github.com/swaywm/swaybg) + [swww](https://github.com/LGFae/swww)
- **锁屏** [swaylock](https://github.com/swaywm/swaylock)
- **注销菜单** [wlogout](https://github.com/ArtsyMacaw/wlogout)
- **终端** [Alacritty](https://github.com/alacritty/alacritty) / [foot](https://codeberg.org/dnkl/foot)
- **Shell** [fish](https://fishshell.com/)
- **输入法** [fcitx5](https://fcitx-im.org/wiki/Fcitx_5) + [Rime](https://rime.im/) (小鹤双拼)
- **SSH** openssh-server
- **编辑器** Neovim + Helix
- **Python** uv

## 特性

> [!NOTE]
> 当前配置适配 [niri v25.11](https://github.com/YaLTeR/niri/releases/tag/v25.11)

- waybar + fuzzel + mako + swaylock 完整桌面体验
- 空闲时间和电源模式可通过 waybar 组件和 fuzzel 菜单切换
- 壁纸切换脚本，自动生成模糊 overview 背景
- 统一的配色方案
- 简洁美观的 UI

## 安装

```bash
git clone https://github.com/optiona1/workspace-config.git
cd workspace-config
./setup.sh
```

脚本会自动从 openSUSE 官方仓库和 Packman 安装所需软件包，并部署配置文件。

> [!IMPORTANT]
> 安装脚本仅支持 openSUSE Tumbleweed 及其衍生版本。

## 备份与恢复

部署配置时会自动备份原有配置，保留最近 3 个备份。

```bash
# 查看可用备份
./setup.sh --list-backups

# 恢复最新备份
./setup.sh --restore

# 恢复指定备份
./setup.sh --restore 20240101_120000

# 仅部署配置（跳过软件安装）
./setup.sh --skip-install
```

备份文件存储在 `~/.config/niri-backups/` 目录下。

## 安装后

1. 注销或重启电脑
2. 通过 tuigreet 登录（greetd 显示管理器）
3. 打开终端测试输入法（<kbd>Super</kbd>+<kbd>Space</kbd> 切换）

## 快捷键

### 应用程序

| 按键 | 功能 |
| :--- | :--- |
| <kbd>Super</kbd> + <kbd>Space</kbd> | 打开启动器 (Fuzzel) |
| <kbd>Super</kbd> + <kbd>Return</kbd> | 打开终端 (Alacritty) |
| <kbd>Super</kbd> + <kbd>B</kbd> | 打开浏览器 (Zen) |
| <kbd>Super</kbd> + <kbd>E</kbd> | 打开文件管理器 (Nautilus) |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>L</kbd> | 锁屏 |
| <kbd>Super</kbd> + <kbd>P</kbd> | 剪贴板菜单 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>T</kbd> | 空闲时间菜单 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>P</kbd> | 电源模式菜单 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>B</kbd> | 切换状态栏 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>W</kbd> | 壁纸选择器 |
| <kbd>Super</kbd> + <kbd>Backspace</kbd> | 注销菜单 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>/</kbd> | 显示热键覆盖 |

### 亮度和音量

| 按键 | 功能 |
| :--- | :--- |
| <kbd>XF86MonBrightnessUp</kbd> | 增加亮度 5% |
| <kbd>XF86MonBrightnessDown</kbd> | 降低亮度 5% |
| <kbd>XF86AudioRaiseVolume</kbd> | 增加音量 5% |
| <kbd>XF86AudioLowerVolume</kbd> | 降低音量 5% |
| <kbd>XF86AudioMute</kbd> | 静音切换 |
| <kbd>XF86AudioMicMute</kbd> | 麦克风静音 |
| <kbd>XF86AudioPlay</kbd> | 播放/暂停 |
| <kbd>XF86AudioNext</kbd> | 下一首 |
| <kbd>XF86AudioPrev</kbd> | 上一首 |

### 窗口和列

| 按键 | 功能 |
| :--- | :--- |
| <kbd>Super</kbd> + <kbd>Q</kbd> | 关闭窗口 |
| <kbd>Super</kbd> + <kbd>R</kbd> | 切换列宽预设 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> | 切换窗口高度预设 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>R</kbd> | 重置窗口高度 |
| <kbd>Super</kbd> + <kbd>F</kbd> | 最大化列 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>F</kbd> | 全屏窗口 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>F</kbd> | 展开列到可用宽度 |
| <kbd>Super</kbd> + <kbd>C</kbd> | 居中列 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>C</kbd> | 居中可见列 |
| <kbd>Super</kbd> + <kbd>Minus</kbd> | 列宽减小 10% |
| <kbd>Super</kbd> + <kbd>Equal</kbd> | 列宽增加 10% |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Minus</kbd> | 窗口高度减小 10% |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Equal</kbd> | 窗口高度增加 10% |
| <kbd>Super</kbd> + <kbd>V</kbd> | 切换浮动窗口 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> | 在浮动和平铺间切换焦点 |
| <kbd>Super</kbd> + <kbd>W</kbd> | 切换列标签显示 |
| <kbd>Super</kbd> + <kbd>BracketLeft</kbd> | 合并/分离左侧列 |
| <kbd>Super</kbd> + <kbd>BracketRight</kbd> | 合并/分离右侧列 |
| <kbd>Super</kbd> + <kbd>Period</kbd> | 从列中分离窗口 |
| <kbd>Super</kbd> + <kbd>H</kbd> | 聚焦左侧列 |
| <kbd>Super</kbd> + <kbd>J</kbd> | 聚焦下方窗口 |
| <kbd>Super</kbd> + <kbd>K</kbd> | 聚焦上方窗口 |
| <kbd>Super</kbd> + <kbd>L</kbd> | 聚焦右侧列 |
| <kbd>Super</kbd> + <kbd>←</kbd> | 聚焦左侧列 |
| <kbd>Super</kbd> + <kbd>→</kbd> | 聚焦右侧列 |
| <kbd>Super</kbd> + <kbd>↓</kbd> | 聚焦下方窗口 |
| <kbd>Super</kbd> + <kbd>↑</kbd> | 聚焦上方窗口 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>H</kbd> | 移动列到左侧 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>J</kbd> | 移动窗口向下 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>K</kbd> | 移动窗口向上 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>L</kbd> | 移动列到右侧 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>←</kbd> | 移动列到左侧 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>→</kbd> | 移动列到右侧 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>↓</kbd> | 移动窗口向下 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>↑</kbd> | 移动窗口向上 |
| <kbd>Super</kbd> + <kbd>Home</kbd> | 聚焦第一列 |
| <kbd>Super</kbd> + <kbd>End</kbd> | 聚焦最后一列 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Home</kbd> | 移动列到首位 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>End</kbd> | 移动列到末位 |

### 显示器和工作区

| 按键 | 功能 |
| :--- | :--- |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>H</kbd> | 聚焦左侧显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>J</kbd> | 聚焦下方显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>K</kbd> | 聚焦上方显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>L</kbd> | 聚焦右侧显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>←</kbd> | 聚焦左侧显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>→</kbd> | 聚焦右侧显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>↓</kbd> | 聚焦下方显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>↑</kbd> | 聚焦上方显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Ctrl</kbd> + <kbd>H</kbd> | 移动列到左侧显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Ctrl</kbd> + <kbd>J</kbd> | 移动列到下方显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Ctrl</kbd> + <kbd>K</kbd> | 移动列到上方显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Ctrl</kbd> + <kbd>L</kbd> | 移动列到右侧显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Ctrl</kbd> + <kbd>←</kbd> | 移动列到左侧显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Ctrl</kbd> + <kbd>→</kbd> | 移动列到右侧显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Ctrl</kbd> + <kbd>↓</kbd> | 移动列到下方显示器 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Ctrl</kbd> + <kbd>↑</kbd> | 移动列到上方显示器 |
| <kbd>Super</kbd> + <kbd>1-9</kbd> | 聚焦工作区 1-9 |
| <kbd>Super</kbd> + <kbd>PageDown</kbd> | 聚焦下方工作区 |
| <kbd>Super</kbd> + <kbd>PageUp</kbd> | 聚焦上方工作区 |
| <kbd>Super</kbd> + <kbd>U</kbd> | 聚焦下方工作区 |
| <kbd>Super</kbd> + <kbd>I</kbd> | 聚焦上方工作区 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>1-9</kbd> | 移动列到工作区 1-9 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>PageDown</kbd> | 移动列到下方工作区 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>PageUp</kbd> | 移动列到上方工作区 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>U</kbd> | 移动列到下方工作区 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>I</kbd> | 移动列到上方工作区 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>PageDown</kbd> | 移动工作区到下方 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>PageUp</kbd> | 移动工作区到上方 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>U</kbd> | 移动工作区到下方 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>I</kbd> | 移动工作区到上方 |
| <kbd>Super</kbd> + <kbd>O</kbd> | 切换 overview |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>WheelUp</kbd> | 移动列到上方工作区 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>WheelDown</kbd> | 移动列到下方工作区 |
| <kbd>Super</kbd> + <kbd>WheelUp</kbd> | 聚焦上方工作区 |
| <kbd>Super</kbd> + <kbd>WheelDown</kbd> | 聚焦下方工作区 |

### 截图

| 按键 | 功能 |
| :--- | :--- |
| <kbd>Super</kbd> + <kbd>A</kbd> | 截图 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>A</kbd> | 交互式截图 (Satty) |
| <kbd>Ctrl</kbd> + <kbd>Print</kbd> | 屏幕截图 |
| <kbd>Alt</kbd> + <kbd>Print</kbd> | 窗口截图 |

### 系统

| 按键 | 功能 |
| :--- | :--- |
| <kbd>Super</kbd> + <kbd>Escape</kbd> | 切换快捷键抑制 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd> | 退出 niri |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Delete</kbd> | 退出 niri |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> | 关闭显示器 |
