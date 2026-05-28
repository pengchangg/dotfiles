# Neovim 配置

这是一个基于 **Neovim 0.12+** 和内置 `vim.pack` 的模块化配置。入口文件保持很薄，主要配置按职责拆分到 `lua/config/` 和 `lua/plugins/` 下，方便维护和扩展。

## 目录结构

```text
.
├── init.lua
├── nvim-pack-lock.json
└── lua
    ├── config
    │   ├── commands.lua    # 自定义用户命令
    │   ├── keymaps.lua     # 全局快捷键
    │   ├── languages.lua   # Treesitter / LSP / formatter / linter 列表
    │   ├── lsp.lua         # 内置 LSP 配置
    │   └── options.lua     # Neovim 基础选项
    └── plugins
        └── init.lua        # 插件安装列表和插件配置
```

`init.lua` 只负责按顺序加载模块：

```lua
require("config.options")
require("plugins")
require("config.lsp")
require("config.keymaps")
require("config.commands")
```

## 要求

- Neovim `0.12+`
- 建议安装 [ripgrep](https://github.com/BurntSushi/ripgrep)，用于 `grepprg` 和 Telescope live grep
- 各语言对应的 LSP / formatter / linter 需要自行安装到 `$PATH`

当前 Lua formatter 使用：

```bash
stylua --version
```

## 首次安装

打开 Neovim 后插件会通过 `vim.pack.add()` 管理。

首次安装或更新后建议执行：

```vim
:TSUpdate
:call firenvim#install(0)
```

如果只想验证配置能否加载：

```bash
nvim --headless -u init.lua +'lua print("config loaded")' +qa
```

## 主要功能

### UI / 编辑体验

- 主题：`gruvbox.nvim`
- 状态栏：`lualine.nvim`
- Buffer 栏：`bufferline.nvim`
- 文件树：`neo-tree.nvim`
- 缩进线：`indent-blankline.nvim`
- 快捷键提示：`which-key.nvim`
- 鼠标启用、相对行号、持久 undo、全局 statusline
- 默认 `textwidth` / `colorcolumn` 为 `80`
  - Python 使用 `88`
  - Rust / Zig 使用 `100`

### 补全

使用 `blink.cmp`，默认来源：

- LSP
- path
- snippets
- buffer

### Treesitter

配置在 `lua/config/languages.lua` 的 `TS_PACKAGES` 中维护。

会自动安装缺失 parser，并启用：

- Treesitter 高亮 / indent
- Treesitter fold
- Treesitter textobjects movement

### LSP

LSP 列表维护在 `lua/config/languages.lua` 的 `LSPS` 中。

当前启用：

- `basedpyright`
- `clangd`
- `gopls`
- `hls`
- `jsonls`
- `lua_ls`
- `nixd`
- `ruff`
- `tinymist`
- `tombi`
- `ts_ls`
- `yamlls`
- `zls`

LSP 配置位于 `lua/config/lsp.lua`，包括：

- 全局 root marker：`.git`
- Lua / Typst / JSON / Go 的 server-specific settings
- LspAttach 后启用 inlay hints
- buffer-local LSP 快捷键

### 格式化和 lint

格式化由 `conform.nvim` 管理，配置位于：

- formatter 列表：`lua/config/languages.lua`
- conform setup：`lua/plugins/init.lua`

手动格式化：

```vim
<leader>cf
```

当前 formatter 映射：

| 文件类型 | Formatter |
|---|---|
| `html` | `prettier` |
| `json` | `prettier` |
| `lua` | `stylua` |
| `nix` | `nixfmt` |
| `python` | `ruff_fix`, `ruff_organize_imports`, `ruff_format` |
| `rust` | `rustfmt` |
| `sh` | `shfmt` |
| `toml` | `tombi` |
| `typst` | `typstyle` |
| `yaml` | `yamlfmt` |

Lint 由 `nvim-lint` 管理，在 `BufWritePost`、`BufReadPost`、`InsertLeave` 时触发。

当前 linter 映射：

| 文件类型 | Linter |
|---|---|
| `go` | `golangcilint` |
| `sh` | `shellcheck` |
| `toml` | `tombi` |

## 快捷键

Leader：`<Space>`  
Local leader：`<Space>`

### 导航

| 快捷键 | 功能 |
|---|---|
| `j` / `<Down>` | 按显示行向下移动 |
| `k` / `<Up>` | 按显示行向上移动 |
| `<C-h>` | 移动到左侧窗口 |
| `<C-j>` | 移动到下方窗口 |
| `<C-k>` | 移动到上方窗口 |
| `<C-l>` | 移动到右侧窗口 |
| `<A-j>` | 向下移动当前行 / 选区 |
| `<A-k>` | 向上移动当前行 / 选区 |

### Buffer

| 快捷键 | 功能 |
|---|---|
| `<S-h>` | 上一个 buffer |
| `<S-l>` | 下一个 buffer |
| `<leader>bd` | 删除当前 buffer，尽量保留窗口 |
| `<leader>bo` | 删除其他 buffer |
| `<leader>bD` | 删除 buffer 和窗口 |
| `<leader>bp` | Toggle pin |
| `<leader>bP` | 删除非 pinned buffers |

### 搜索 / 列表 / 诊断

| 快捷键 | 功能 |
|---|---|
| `<Esc>` | 清除搜索高亮并退出当前模式 |
| `n` / `N` | 下一个 / 上一个搜索结果 |
| `<leader>xl` | 打开 / 关闭 location list |
| `<leader>xq` | 打开 / 关闭 quickfix list |
| `[q` / `]q` | 上一个 / 下一个 quickfix |
| `<leader>cd` | 当前行诊断浮窗 |
| `[d` / `]d` | 上一个 / 下一个诊断 |
| `[e` / `]e` | 上一个 / 下一个错误 |
| `[w` / `]w` | 上一个 / 下一个警告 |

### Telescope / 文件 / 代码动作

| 快捷键 | 功能 |
|---|---|
| `<leader><Space>` | 查找文件 |
| `<leader>/` | 全文搜索 |
| `<leader>,` | 切换 buffer |
| `<leader>:` | 命令历史 |
| `<leader>e` | 打开 / 关闭 Neo-tree |
| `<leader>cf` | 格式化当前文件 |
| `<leader>ca` | Code action |

### Flash / 其他

| 快捷键 | 功能 |
|---|---|
| `s` | Flash jump |
| `S` | Flash Treesitter |
| `<C-s>` | 保存文件 |
| `<leader>K` | 执行原始 `K` keywordprg |
| `<leader>fn` | 新建空 buffer |
| `<leader>qq` | 退出全部 |
| `<A-q>` | 退出 terminal mode |
| `<leader>?` | 显示当前 buffer 的 which-key 快捷键 |

### LSP buffer-local 快捷键

这些快捷键在 LSP attach 后启用：

| 快捷键 | 功能 |
|---|---|
| `K` | Hover |
| `gd` | 跳转定义 |
| `gD` | 跳转声明 |
| `gr` | 查看引用 |
| `gi` | 跳转实现 |
| `gt` | 跳转类型定义 |
| `<leader>cr` | 重命名符号 |
| `<C-k>` | Signature help |

Rust 额外快捷键：

| 快捷键 | 功能 |
|---|---|
| `<leader>cR` | Rust code action |
| `<leader>dr` | Rust debuggables |

## 自定义命令

| 命令 | 功能 |
|---|---|
| `:LspInfo` | 显示当前 buffer 附着的 LSP clients |
| `:LspLog` | 打开 LSP log |
| `:LspRestart` | 重启当前 buffer 的 LSP clients |
| `:Run <cmd>` | 在底部分屏运行 shell 命令并显示输出 |
| `:TypstPin` | 调用 `tinymist.pinMain` 固定当前 Typst 主文件 |

## Firenvim

Firenvim 配置为不自动接管网页输入框：

```lua
takeover = "never"
```

需要时可以通过 Firenvim 手动打开。

## 维护方式

### 添加 LSP

编辑 `lua/config/languages.lua`：

```lua
M.LSPS = {
  "lua_ls",
  -- add new server here
}
```

如果需要 server-specific 配置，放到 `lua/config/lsp.lua`：

```lua
vim.lsp.config("server_name", {
  settings = {},
})
```

### 添加 formatter / linter

formatter 加到 `M.FORMATTERS`：

```lua
M.FORMATTERS = {
  lua = { "stylua" },
}
```

linter 加到 `M.LINTERS`：

```lua
M.LINTERS = {
  sh = { "shellcheck" },
}
```

确保对应命令已安装并在 `$PATH` 中，例如：

```bash
command -v stylua
```

### 添加插件

在 `lua/plugins/init.lua` 的 `vim.pack.add({ ... })` 中添加仓库 URL，然后在同一文件中添加对应 setup。

## 常见问题

### `Formatters unavailable for lua file`

通常是 formatter 命令没有安装，检查：

```bash
command -v stylua
```

如果没有输出，需要安装 `stylua`。

也可以在 Neovim 中查看 Conform 状态：

```vim
:ConformInfo
```

### Swapfile 提示

如果看到类似：

```text
W325: Ignoring swapfile from Nvim process ...
```

通常表示同一个文件正在被另一个 Neovim 进程打开，或上次异常退出留下了 swapfile。确认没有其他进程在编辑后，可以按提示删除对应 swapfile。

## 验证命令

```bash
# 检查配置能否加载
nvim --headless -u init.lua +'lua print("config loaded")' +qa

# 检查 Lua 代码格式
stylua --check init.lua lua/**/*.lua
```
