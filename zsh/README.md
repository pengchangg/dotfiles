# Zsh 配置

macOS 默认 shell，对标 Linux 的 bash 配置包。

## 路由关系

```
zsh startup
  → ~/.zshenv → .config/zsh/zshenv     (环境变量)
  → ~/.zshrc  → .config/zsh/zshrc      (交互配置 → fzf.zsh)
```

## 文件说明

| 文件 | 用途 |
|------|------|
| `.zshrc` | 路由桩 → `.config/zsh/zshrc` |
| `.zshenv` | 路由桩 → `.config/zsh/zshenv` |
| `.config/zsh/zshrc` | 主配置（prompt、alias、选项、completion） |
| `.config/zsh/zshenv` | 环境变量 |
| `.config/zsh/fzf.zsh` | fzf 集成（`fzf --zsh`，跨平台） |
| `.config/starship.toml` | prompt 配置（与 bash 包共享同一文件） |

## 功能对等

与 bash 配置包完全对等：starship prompt、fzf 快捷键（Ctrl+R/T、Alt+C、Ctrl+O）、ripgrep/fd/bat 别名、lf 文件管理器、git 快捷 alias。

## 平台差异

唯一需要平台判断的是 `ls` 的颜色 flag：

| 平台 | ls flag |
|------|---------|
| macOS (BSD) | `-G` |
| Linux (GNU)  | `--color=auto` |

通过 `uname` 自动检测。

## 依赖

| 工具 | macOS 安装 |
|------|-----------|
| zsh | 系统自带 |
| starship | `brew install starship` |
| fzf | `brew install fzf` |
| ripgrep | `brew install ripgrep` |
| fd | `brew install fd` |
| bat | `brew install bat` |
