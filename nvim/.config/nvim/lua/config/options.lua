-- Core Neovim options and UI-related autocmds.

-- ╭──────────────────────────────────────────────────────────────────────╮
-- │                              OPTIONS                                 │
-- ╰──────────────────────────────────────────────────────────────────────╯

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Local settings
vim.opt.exrc = true
vim.opt.secure = true

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Persistence
vim.opt.confirm = true
vim.opt.undofile = true
vim.opt.undolevels = 1000000

-- Mouse & clipboard
vim.opt.mouse = "a"

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.shiftround = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Formatting
vim.opt.formatoptions = "jcroqlnt"

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "nosplit"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

-- UI
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.ruler = true
vim.opt.laststatus = 3
vim.opt.termguicolors = true
vim.opt.textwidth = 80
vim.opt.colorcolumn = "80"
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "rust", "zig" },
	callback = function()
		-- Wider ruler for languages with longer line conventions
		vim.opt_local.colorcolumn = "100"
		vim.opt_local.textwidth = 100
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python" },
	callback = function()
		-- Wider ruler for languages with longer line conventions
		vim.opt_local.colorcolumn = "88"
		vim.opt_local.textwidth = 88
	end,
})
vim.opt.showmode = false

-- Scrolling & windows
vim.opt.winminwidth = 5
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "screen"

-- Wrapping & display
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.list = false

-- Folding
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99
vim.opt.foldtext = "v:lua.vim.fn.getline(v:foldstart) .. ' ...'"

-- Misc
vim.opt.jumpoptions = "view"
vim.opt.virtualedit = "block"
vim.opt.wildmode = "longest:full,full"
