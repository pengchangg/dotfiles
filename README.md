# Dotfiles

跨平台终端环境配置（Arch / Debian / RHEL / macOS），GNU stow + git 管理，GPG 签名所有 commit。私密文件通过 git-crypt 加密。

## 模块

| 模块 | 内容 | 加密 |
|------|------|------|
| git | GPG 签名、默认分支 | 📄 |
| gnupg | pinentry 配置（不含私钥） | 📄 |
| bash | XDG 路由、fzf 快捷键、starship prompt + git_status、alias | 📄 |
| lf | 三栏布局、预览系统、vim 键位 | 📄 |
| tmux | 多路复用、pane 导航、复制模式、tpm 插件 | 📄 |
| nvim | vim.pack.add() 原生管理、gruvbox、blink.cmp、30+ 插件、13 LSP | 📄 |
| ssh | SSH 密钥、客户端 config、known_hosts | 🔒 git-crypt |

## 快速开始（新机器）

```bash
# 1. 安装系统依赖
# Arch
pacman -S --needed - < ~/.dotfiles/packages.arch.txt
# Debian / Ubuntu
xargs -a ~/.dotfiles/packages.debian.txt apt-get install -y
# RHEL / AlmaLinux (需要先启用 EPEL: dnf install -y epel-release)
dnf install -y $(cat ~/.dotfiles/packages.rhel.txt)
# macOS
brew bundle --file=~/.dotfiles/Brewfile

# 2. 导入 GPG 私钥（签名 + 解密 git-crypt）
gpg --import gpg-backup.asc

# 3. 克隆 + 一键部署
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles && ./bootstrap.sh
```

或手动逐步：

```bash
git clone <repo-url> ~/.dotfiles && cd ~/.dotfiles
gpg --import gpg-backup.asc
git-crypt unlock
stow git gnupg bash lf tmux nvim ssh
chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_* ~/.ssh/dev* ~/.ssh/*.pem
```

## 添加新模块

```bash
mkdir -p ~/.dotfiles/<name>/.config/<name>
# 复制配置文件，保持 ~ 目录镜像结构
cd ~/.dotfiles && stow <name>
git add -A && git commit -S -m "add <name> config"
```

## 加密私密模块

使用 git-crypt + GPG 加密：

```bash
# install git-crypt (see dependency table above for your distro)
cd ~/.dotfiles && git-crypt init
git-crypt add-gpg-user <KEY-ID>
echo "module/**/secret filter=git-crypt diff=git-crypt" >> .gitattributes
```

加密文件在磁盘上是明文（SSH 等工具可直接使用），仅在 git 对象存储中是密文。

## 依赖

完整系统包清单见 `packages.<distro>.txt` 和 `Brewfile`。

| 工具 | 用途 | Arch | Debian | RHEL | macOS |
|------|------|------|--------|------|-------|
| stow | 符号链接管理 | pacman | apt | dnf (EPEL) | brew |
| git-crypt | 加密私密文件 | pacman | apt | dnf (EPEL) | brew |
| gnupg | GPG 签名 + 解密 | pacman | apt | dnf (gnupg2) | brew |
| neovim (>=0.12) | 编辑器 | pacman | apt | dnf (EPEL) | brew |
| tree-sitter-cli | TS parser 编译 | pacman | apt | — | brew |
| starship | prompt | curl | curl | curl | brew |
| fzf | 模糊搜索 | pacman | apt | dnf (EPEL) | brew |
| ripgrep | 替代 grep | pacman | apt | dnf (EPEL) | brew |
| fd | 替代 find | pacman | apt (fd-find) | dnf (fd-find) | brew |
| bat | 语法高亮预览 | pacman | apt | 手动 | brew |
| glow | Markdown 渲染 | pacman | apt | 手动 | brew |
| lf | 文件管理器 | pacman | apt | 手动 | brew |
| tmux | 终端多路复用 | pacman | apt | dnf | brew |

**RHEL 注意**: `bat`、`glow`、`lf` 不在 RHEL/EPEL 仓库中，需从 GitHub Releases 手动安装。`tree-sitter-cli` 可通过 `npm install -g tree-sitter-cli` 或 `cargo install tree-sitter-cli` 安装。

## 设计原则

- XDG 目录规范 — ~ 目录只保留路由桩和符号链接
- GPG 签名 — 所有 commit 和 tag 自动签名
- SSH 友好 — 无 NERD Fonts，16 色 ANSI
- 模块化 — 每个工具的配置独立一个 stow package
- 私密优先 — SSH 密钥等敏感文件默认加密，私钥仅离线备份传递
- 极简 prompt — 目录 + git 分支 + 仓库状态
- 一键还原 — `./bootstrap.sh` 从零到可用
