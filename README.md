# Dotfiles

Arch Linux 终端环境配置，GNU stow + git 管理。

## 模块

| 模块 | 内容 | 文件 |
|------|------|------|
| bash | XDG 路由、fzf 快捷键、starship prompt、alias | `.bashrc` `.bash_profile` `.profile` `.config/bash/` `.config/starship.toml` |
| lf | 三栏布局文件管理器、预览系统、vim 键位 | `.config/lf/lfrc` `.config/lf/pv.sh` |
| tmux | 终端多路复用、pane 导航、复制模式、tpm 插件 | `.tmux.conf` |

## 快速开始（新机器）

```bash
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles && stow bash lf tmux
```

## 添加新模块

```bash
mkdir -p ~/.dotfiles/<name>/.config/<name>
# 复制配置文件，保持 ~ 目录镜像结构
cd ~/.dotfiles && stow <name>
git add -A && git commit -m "add <name> config"
```

## 依赖

| 工具 | 用途 | 安装 |
|------|------|------|
| stow | 符号链接管理 | `pacman -S stow` |
| starship | prompt | `curl -sS https://starship.rs/install.sh \| sh` |
| fzf | 模糊搜索 | `pacman -S fzf` |
| ripgrep | 替代 grep | `pacman -S ripgrep` |
| fd | 替代 find | `pacman -S fd` |
| bat | 语法高亮预览 | `pacman -S bat` |
| glow | Markdown 渲染 | `pacman -S glow` |
| lf | 文件管理器 | `pacman -S lf` |
| tmux | 终端多路复用 | `pacman -S tmux` |

## 设计原则

- XDG 目录规范 — ~ 目录只保留路由桩
- SSH 友好 — 无 NERD Fonts，16 色 ANSI
- 模块化 — 每个工具的配置独立管理
- 极简 prompt — 仅目录 + git 分支
