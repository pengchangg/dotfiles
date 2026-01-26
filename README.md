# Dotfiles

个人 Linux 开发环境配置文件集合，使用 [GNU Stow](https://www.gnu.org/software/stow/) 进行统一管理。

## 📦 包含的配置

- **bash** - Bash shell 配置（模块化设计）
- **nvim** - Neovim 编辑器配置
- **tmux** - 终端复用器配置
- **git-workfow** - Git 配置和工作流脚本
- **bat** - 代码高亮工具配置

## 🚀 快速开始

### 前置要求

- GNU Stow（通常已预装，如未安装：`sudo pacman -S stow` 或 `sudo apt install stow`）
- Git

### 安装步骤

1. **克隆仓库到 `~/.dotfiles`**

```bash
git clone https://github.com/pengchangg/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. **使用管理脚本安装（推荐）**

```bash
# 使用脚本自动安装（会自动备份现有配置）
./manage.sh restore

# 或者手动使用 Stow
stow bash nvim tmux git-workfow bat
```

3. **验证安装**

```bash
# 检查配置状态
./manage.sh status

# 或手动检查符号链接
ls -la ~/.bashrc
ls -la ~/.config/nvim/init.lua
ls -la ~/.tmux.conf
```

### 卸载配置

```bash
# 使用脚本卸载（推荐）
./manage.sh reset

# 或手动使用 Stow
stow -D bash nvim tmux git-workfow bat
```

## 📁 项目结构

```
dotfiles/
├── manage.sh                # 管理脚本（恢复/重置）
├── bash/                    # Bash 配置
│   ├── .bashrc             # 主配置文件
│   ├── .profile            # 登录 shell 配置
│   └── .bashrc.d/          # 模块化配置目录
│       ├── 00-env.sh       # 环境变量
│       ├── 05-keybind.sh   # 快捷键绑定
│       ├── 10-alias.sh     # 命令别名
│       ├── 20-prompt.sh     # 提示符配置
│       ├── 30-tools.sh     # 工具集成
│       ├── 40-fzf.sh       # fzf 配置
│       ├── 99-go.sh        # Go 环境
│       └── 99-cursor.sh    # Cursor IDE 配置
├── nvim/                    # Neovim 配置
│   └── .config/
│       └── nvim/
│           └── init.lua
├── tmux/                    # Tmux 配置
│   └── .tmux.conf
├── git-workfow/             # Git 配置
│   ├── .gitconfig          # Git 全局配置
│   └── .git-workflow.sh    # Git 工作流脚本
└── bat/                     # Bat 配置
    └── .config/
        └── bat/
            └── config
```

## 🔧 配置说明

### Bash

模块化设计的 Bash 配置，包含：
- 历史记录优化（50000 条）
- 常用命令别名
- Git 状态提示符
- fzf 模糊搜索集成
- tmux 快捷命令
- Go 开发环境配置

**私有配置**：支持 `~/.bashrc.local` 文件存放个人私有配置（不会被 Git 跟踪）

### Neovim

基础 Neovim 配置，特性：
- 行号和相对行号
- 空格键作为 Leader 键
- 窗口管理和 Buffer 切换
- 自动恢复上次编辑位置

### Tmux

终端复用器配置，包含：
- Alt+hjkl 切换窗格
- 简洁的状态栏
- Vim 键位支持

### Git Workflow

Git 工作流脚本，提供便捷命令：
- `gfeat <name>` - 创建功能分支
- `gfix <name>` - 创建修复分支
- `gcm "message"` - 提交更改
- `gmerge` - 合并到 main
- `gdone` - 合并并清理分支
- `gtag vX.Y.Z "msg"` - 创建标签

运行 `ghelp` 查看所有可用命令。

### Bat

代码高亮工具配置，使用 TwoDark 主题。

## 🔐 安全说明

- SSH 密钥等敏感文件使用 `git-crypt` 加密（见 `.gitattributes`）
- 个人私有配置应放在 `~/.bashrc.local`（不会被 Git 跟踪）

## 📝 维护

### 添加新配置

1. 在对应目录创建配置文件（保持目录结构与目标路径一致）
2. 使用 `stow <package-name>` 安装

### 更新配置

```bash
cd ~/.dotfiles
git pull
stow -R bash nvim tmux git-workfow bat  # -R 表示重新安装
```

### 修改配置

直接编辑 `~/.dotfiles` 目录下的文件，修改会自动反映到符号链接的目标位置。

## 🛠️ 管理脚本

项目提供了 `manage.sh` 脚本，方便管理 dotfiles：

```bash
# 恢复/安装所有配置（会自动备份现有配置）
./manage.sh restore

# 重置/卸载所有配置
./manage.sh reset

# 备份现有配置（不安装）
./manage.sh backup

# 检查配置状态
./manage.sh status

# 显示帮助信息
./manage.sh help
```

### Stow 常用命令（手动管理）

如果需要手动管理，可以使用以下命令：

```bash
# 安装配置包
stow <package-name>

# 卸载配置包
stow -D <package-name>

# 重新安装（先卸载再安装）
stow -R <package-name>

# 模拟安装（不实际创建链接）
stow -n <package-name>

# 详细输出
stow -v <package-name>
```

## 🙏 致谢

感谢所有开源社区的工具和配置分享。
