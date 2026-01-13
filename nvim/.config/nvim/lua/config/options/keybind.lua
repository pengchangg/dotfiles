-- ========================================================================== --
--                                快捷键映射                                  --
-- ========================================================================== --

-- 设置 Leader 键为空格
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set

-- 快速保存与退出
keymap("n", "<leader>w", ":w<CR>", { desc = "保存" })
keymap("n", "<leader>q", ":q<CR>", { desc = "退出" })

-- <Esc><Esc> :nohl
keymap("n", "<Esc><Esc>", ":nohl<CR>", { desc = "退出" })

-- 窗口管理
keymap("n", "<leader>sv", "<C-w>v", { desc = "垂直分屏" })
keymap("n", "<leader>sh", "<C-w>s", { desc = "水平分屏" })

-- 视觉模式下移动选中文本
keymap("v", "J", ":m '>+1<CR>gv=gv")
keymap("v", "K", ":m '<-2<CR>gv=gv")

-- 快速切换 Buffer (无插件下的标签页替代品)
keymap("n", "<S-L>", ":bnext<CR>")
keymap("n", "<S-H>", ":bprevious<CR>")

keymap('n', '<Tab>', ':BufferLineCycleNext<CR>', {silent=true})
keymap('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', {silent=true})

