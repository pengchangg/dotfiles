# Dotfiles

Arch Linux 终端环境配置，GNU stow + git 管理，GPG 签名所有 commit。私密文件通过 git-crypt 加密。

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
pacman -S --needed - < ~/.dotfiles/packages.txt

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
pacman -S git-crypt
cd ~/.dotfiles && git-crypt init
git-crypt add-gpg-user <KEY-ID>
echo "module/**/secret filter=git-crypt diff=git-crypt" >> .gitattributes
```

加密文件在磁盘上是明文（SSH 等工具可直接使用），仅在 git 对象存储中是密文。

## 依赖

完整系统包清单见 `packages.txt`（`pacman -S --needed - < packages.txt` 一键安装）。

| 工具 | 用途 | 安装 |
|------|------|------|
| stow | 符号链接管理 | `pacman -S stow` |
| git-crypt | 加密私密文件 | `pacman -S git-crypt` |
| gnupg | GPG 签名 + git-crypt 解密 | `pacman -S gnupg` |
| neovim (>=0.12) | 编辑器 | `pacman -S neovim` |
| tree-sitter-cli | nvim treesitter parser 编译 | `pacman -S tree-sitter-cli` |
| starship | prompt | `curl -sS https://starship.rs/install.sh \| sh` |
| fzf | 模糊搜索 | `pacman -S fzf` |
| ripgrep | 替代 grep | `pacman -S ripgrep` |
| fd | 替代 find | `pacman -S fd` |
| bat | 语法高亮预览 | `pacman -S bat` |
| glow | Markdown 渲染 | `pacman -S glow` |
| lf | 文件管理器 | `pacman -S lf` |
| tmux | 终端多路复用 | `pacman -S tmux` |

## 设计原则

- XDG 目录规范 — ~ 目录只保留路由桩和符号链接
- GPG 签名 — 所有 commit 和 tag 自动签名
- SSH 友好 — 无 NERD Fonts，16 色 ANSI
- 模块化 — 每个工具的配置独立一个 stow package
- 私密优先 — SSH 密钥等敏感文件默认加密，私钥仅离线备份传递
- 极简 prompt — 目录 + git 分支 + 仓库状态
- 一键还原 — `./bootstrap.sh` 从零到可用
