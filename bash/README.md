# Bash 配置

XDG 风格路由的 Bash 配置，prompt、快捷键、alias 拆分为独立模块。

## 路由关系

```
SSH 登录 (login shell)
  → ~/.bash_profile → .config/bash/profile
  → ~/.bashrc       → .config/bash/bashrc → fzf.sh
```

## 文件说明

| 文件 | 用途 |
|------|------|
| `.bashrc` | 路由桩 → `.config/bash/bashrc` |
| `.bash_profile` | 路由桩 → `.config/bash/profile` |
| `.profile` | PATH 注入 (`~/.local/bin/env`) |
| `.config/bash/bashrc` | 主配置（环境变量、alias、选项、fzf 加载） |
| `.config/bash/fzf.sh` | fzf 快捷键模块 |
| `.config/bash/profile` | login shell 入口 |
| `.config/starship.toml` | prompt 配置 |

## 功能

### Prompt (starship)

`目录 git分支 ❯` — 退出码异常时 ❯ 变红。

### fzf 快捷键

| 快捷键 | 功能 |
|--------|------|
| Ctrl+R | 搜索历史（可编辑） |
| Ctrl+T | 选择文件插入路径 |
| Ctrl+O | 选文件 nvim 打开 |
| Alt+C | 选目录 cd |

### 工具替换

| 命令 | 实际调用 |
|------|----------|
| grep | rg |
| find | fd |
| cat  | bat -p |

### 常用 alias

| alias | 展开 |
|-------|------|
| g/gs/gl/gd | git / status / log / diff |
| ll/l | ls -alFh / ls -CF |
| .. / ... | cd .. / cd ../.. |
| l | lfcd (lf 文件管理器) |
| reload | source 重载配置 |

### Shell 选项

- `noclobber` — `>` 不覆盖已有文件
- `histappend` — 多会话共享历史
- `completion-ignore-case` — Tab 补全忽略大小写

## 依赖

| 工具 | 安装 |
|------|------|
| starship | `curl -sS https://starship.rs/install.sh \| sh` |
| fzf | `pacman -S fzf` |
| ripgrep | `pacman -S ripgrep` |
| fd | `pacman -S fd` |
| bat | `pacman -S bat` |
