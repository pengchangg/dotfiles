# Neovim 配置

基于 Neovim 0.12+ 内置 `vim.pack` API，无第三方插件管理器。

## 文件说明

| 文件 | 用途 |
|------|------|
| `init.lua` | 入口：bootstrap 插件克隆 + 加载模块 |
| `lua/config/options.lua` | 编辑器设置 |
| `lua/config/keymaps.lua` | 快捷键（leader=空格） |
| `lua/config/lsp.lua` | LSP 骨架 |
| `lua/plugins/init.lua` | 插件配置（pcall 保护，缺失时优雅降级） |

## 工作方式

首次启动 `nvim` 时，`init.lua` 自动将插件克隆到：
```
~/.local/share/nvim/site/pack/plugins/start/
```
此后插件由 `vim.pack` 自动加载（`start/` 目录内的插件随 nvim 启动即加载）。

## 插件

| 插件 | 用途 |
|------|------|
| treesitter | 语法高亮 + 缩进 |
| telescope | 模糊搜索 |
| lspconfig + mason + cmp | LSP 补全 |
| lualine | 状态栏（无图标） |
| gitsigns | Git 标记 |
| Comment | `gcc` 注释切换 |

## 快捷键

| 键 | 功能 | 键 | 功能 |
|----|------|----|------|
| `<leader>w` | 保存 | `jk` | 退出插入 |
| `<leader>ff` | 搜索文件 | `<leader>fg` | 搜索文本 |
| `<leader>fb` | 切换 buffer | `<leader>h` | 清除高亮 |
| `Ctrl+hjkl` | 切换窗口 | `Ctrl+方向` | 调整窗口 |

## 还原

```bash
cd ~/.dotfiles && stow nvim
# 首次启动自动克隆插件
nvim +qa
```

## 依赖

| 工具 | 安装 |
|------|------|
| neovim (>=0.12) | `pacman -S neovim` |
| git | `pacman -S git` |
| LSP servers | `:Mason` 交互安装 |
