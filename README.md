# Dotfiles

Arch Linux 终端环境配置，GNU stow + git 管理。私密文件通过 git-crypt 加密。

## 模块

| 模块 | 内容 | 加密 |
|------|------|------|
| git | GPG 签名、默认分支 | 📄 |
| bash | XDG 路由、fzf 快捷键、starship prompt、alias | 📄 |
| lf | 三栏布局文件管理器、预览系统、vim 键位 | 📄 |
| tmux | 终端多路复用、pane 导航、复制模式、tpm 插件 | 📄 |
| ssh | SSH 密钥、客户端 config、known_hosts | 🔒 git-crypt |

## 快速开始（新机器）

```bash
# 1. 导入 GPG 私钥（签名 + 解密 git-crypt）
gpg --import gpg-backup.asc

# 2. 克隆仓库
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles

# 3. 解密私密文件
git-crypt unlock

# 4. 部署所有模块
stow git bash lf tmux ssh

# 5. 修正 SSH 密钥权限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_* ~/.ssh/dev* ~/.ssh/prod* ~/.ssh/*.pem
```

## 添加新模块

```bash
mkdir -p ~/.dotfiles/<name>/.config/<name>
# 复制配置文件，保持 ~ 目录镜像结构
cd ~/.dotfiles && stow <name>
git add -A && git commit -m "add <name> config"
```

## 加密私密模块

使用 git-crypt + GPG 加密：

```bash
# 初始化（仅首次）
pacman -S git-crypt
cd ~/.dotfiles && git-crypt init
git-crypt add-gpg-user <KEY-ID>

# 标记加密文件
echo "module/**/secret filter=git-crypt diff=git-crypt" >> .gitattributes
```

加密文件在磁盘上是明文，仅在 git 对象存储中是密文。

## 依赖

| 工具 | 用途 | 安装 |
|------|------|------|
| stow | 符号链接管理 | `pacman -S stow` |
| git-crypt | 加密私密文件 | `pacman -S git-crypt` |
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
- 私密优先 — SSH 密钥等敏感文件默认加密
- 极简 prompt — 仅目录 + git 分支
