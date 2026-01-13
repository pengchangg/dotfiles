-- ========================================================================== --
--                                基础设置                                    --
-- ========================================================================== --

local opt = vim.opt

-- 交互体验
opt.number = true           -- 显示行号
opt.relativenumber = true   -- 相对行号（方便跳转）
opt.scrolloff = 8           -- 光标上下保持 8 行距离
-- opt.mouse = 'a'             -- 启用鼠标支持
opt.cursorline = true       -- 高亮当前行
opt.termguicolors = true    -- 开启 24 位真彩色

-- 缩进设置
opt.tabstop = 4             -- 1个制表符显示为4个空格宽度
opt.shiftwidth = 4          -- 自动缩进时缩进 4 个空格
opt.expandtab = true        -- 将 Tab 转换为空格
opt.smartindent = true      -- 智能缩进

-- 搜索设置
opt.ignorecase = true       -- 搜索忽略大小写
opt.smartcase = true        -- 如果搜索词包含大写，则不忽略大小写

-- 系统集成
opt.undofile = true           -- 开启持久化撤销（重启后仍可撤销）

-- 性能优化
opt.updatetime = 250        -- 响应时间（毫秒）
opt.timeoutlen = 300        -- 按键序列等待时间

vim.g.netrw_banner = 0         -- 隐藏顶部帮助信息
vim.g.netrw_winsize = 25       -- 设置宽度

-- theme
opt.background = "dark"
vim.cmd([[colorscheme catppuccin]])

-- 重新打开文件时自动跳转到上次退出的位置
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
