# Neovim 配置

模块化 lua 配置，基于 lazy.nvim 插件管理。

## 文件说明

| 文件 | 用途 |
|------|------|
| `init.lua` | 入口，bootstrap lazy.nvim + 加载模块 |
| `lua/config/options.lua` | 编辑器设置（行号、缩进、搜索、剪贴板） |
| `lua/config/keymaps.lua` | 快捷键（leader=空格） |
| `lua/config/lsp.lua` | LSP 骨架（按需扩展） |
| `lua/plugins/init.lua` | 插件声明（treesitter、telescope、lsp、lualine） |

## 插件

| 插件 | 用途 |
|------|------|
| treesitter | 语法高亮 + 缩进 |
| telescope | 模糊搜索（文件/文本/buffer） |
| lspconfig + mason | LSP 补全 |
| lualine | 状态栏 |
| gitsigns | Git 增删改标记 |
| Comment | `gcc` 注释切换 |

## 快捷键

> leader = 空格

| 键 | 功能 | 键 | 功能 |
|----|------|----|------|
| `<leader>w` | 保存 | `jk` | 退出插入模式 |
| `<leader>ff` | 搜索文件 | `<leader>fg` | 搜索文本 |
| `<leader>fb` | 切换 buffer | `<leader>h` | 清除搜索高亮 |
| `Ctrl+hjkl` | 切换窗口 | `Ctrl+方向键` | 调整窗口大小 |

## 还原

```bash
cd ~/.dotfiles && stow nvim
# 首次启动自动安装 lazy.nvim 和所有插件
nvim --headless "+Lazy! sync" +qa
```

## 依赖

| 工具 | 安装 |
|------|------|
| neovim | `pacman -S neovim` |
| git | `pacman -S git` |
| LSP servers | `:Mason` 交互安装 |
