-- Editor options

vim.opt.number = true             -- line numbers
vim.opt.relativenumber = true     -- relative line numbers
vim.opt.cursorline = true         -- highlight current line
vim.opt.signcolumn = "yes"        -- always show sign column

vim.opt.tabstop = 2               -- tab = 2 spaces
vim.opt.shiftwidth = 2
vim.opt.expandtab = true          -- spaces, not tabs
vim.opt.autoindent = true

vim.opt.clipboard = "unnamedplus" -- system clipboard
vim.opt.mouse = ""                -- no mouse (terminal-friendly)
vim.opt.termguicolors = true      -- 24-bit color

vim.opt.ignorecase = true         -- case-insensitive search
vim.opt.smartcase = true          -- …unless uppercase in pattern
vim.opt.hlsearch = true           -- highlight matches
vim.opt.incsearch = true          -- incremental search

vim.opt.splitright = true         -- vertical split to the right
vim.opt.splitbelow = true         -- horizontal split below

vim.opt.scrolloff = 5             -- keep 5 lines above/below cursor
vim.opt.sidescrolloff = 8

vim.opt.swapfile = false          -- no swap files
vim.opt.backup = false
vim.opt.undofile = true           -- persistent undo
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

vim.opt.updatetime = 300          -- faster completion
vim.opt.timeoutlen = 400          -- faster key sequence
