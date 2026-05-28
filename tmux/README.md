# tmux 配置

终端多路复用器配置，vim 风格 pane 导航 + tpm 插件管理。

## 文件说明

| 文件 | 用途 |
|------|------|
| `.tmux.conf` | tmux 主配置 |

## 基础设置

| 设置 | 值 | 作用 |
|------|----|------|
| default-terminal | tmux-256color | 256 色支持 |
| base-index | 1 | 窗口 & pane 从 1 开始 |
| escape-time | 10 | 降低 Esc 延迟 |
| history-limit | 10000 | 回滚缓冲区 |
| renumber-windows | on | 关闭窗口后自动重排编号 |

## 界面

- pane 边框 — 非活动 `#555555`，活动 `#00afff`
- 状态栏 — 黑底白字，左 session 名，右日期时间
- 窗口栏 — 当前窗口反色高亮

## 快捷键

> 前缀键 `Ctrl+B`

### Pane 管理
| 键 | 功能 |
|----|------|
| Prefix + \| | 竖直分割 |
| Prefix + - | 水平分割 |
| Prefix + h/j/k/l | 左/下/上/右 pane |
| Alt+Shift + H/J/K/L | 调整 pane 大小 |
| Prefix + space | 循环布局 |

### 复制模式 (vi)
| 键 | 功能 |
|----|------|
| Prefix + v | 进入复制模式 |
| v | 开始选择 |
| y | 复制并退出 |
| Esc | 取消 |

### 其他
| 键 | 功能 |
|----|------|
| Prefix + r | 重载配置 |

## 插件 (tpm)

安装：`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

| 插件 | 用途 |
|------|------|
| tmux-resurrect | 保存/恢复 session |
| tmux-continuum | 自动保存 + 恢复 |
| tmux-sensible | 合理默认值 |
| tmux-prefix-highlight | 状态栏 prefix 指示 |

| 操作 | 快捷键 |
|------|--------|
| 安装插件 | Prefix + I |
| 更新插件 | Prefix + U |
| 卸载插件 | Prefix + Alt + U |

## 依赖

| 工具 | 安装 |
|------|------|
| tmux | `pacman -S tmux` |
| tpm | `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm` |
