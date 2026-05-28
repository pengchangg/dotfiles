-- Plugin installation and plugin-specific setup.

local language = require("config.languages")
local TS_PACKAGES = language.TS_PACKAGES
local FORMATTERS = language.FORMATTERS
local LINTERS = language.LINTERS

-- ╭──────────────────────────────────────────────────────────────────────╮
-- │                              PLUGINS                                 │
-- ╰──────────────────────────────────────────────────────────────────────╯

vim.pack.add({
	-- Colorscheme
	"https://github.com/ellisonleao/gruvbox.nvim",

	-- UI components
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/akinsho/bufferline.nvim",

	-- File explorer
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/antosha417/nvim-lsp-file-operations",
	"https://github.com/nvim-neo-tree/neo-tree.nvim",

	-- Keybinding help
	"https://github.com/folke/which-key.nvim",

	-- Completion
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/saghen/blink.lib",
	"https://github.com/saghen/blink.cmp",

	-- Treesitter
	"https://github.com/nvim-treesitter/nvim-treesitter",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },

	-- Fuzzy finder
	"https://github.com/nvim-telescope/telescope.nvim",

	-- Navigation & motions
	"https://github.com/folke/flash.nvim",
	"https://github.com/mawkler/refjump.nvim",

	-- Text objects & editing
	"https://github.com/echasnovski/mini.ai",
	"https://github.com/echasnovski/mini.surround",
	"https://github.com/gbprod/yanky.nvim",

	-- Visual guides
	"https://github.com/lukas-reineke/indent-blankline.nvim",
	-- TODO: Taking this out since it has bug on recent nightly neovim 0.12
	-- "https://github.com/HiPhish/rainbow-delimiters.nvim",

	-- Formatting & linting
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",

	-- LSP & diagnostics
	"https://github.com/rachartier/tiny-code-action.nvim",
	"https://github.com/rachartier/tiny-inline-diagnostic.nvim",
	"https://github.com/neovim/nvim-lspconfig",

	-- Language-specific
	"https://github.com/mrcjkb/rustaceanvim",
	"https://github.com/saecki/crates.nvim",
	"https://github.com/chomosuke/typst-preview.nvim",

	-- Browser integration
	"https://github.com/glacambre/firenvim",
})

-- ╭──────────────────────────────────────────────────────────────────────╮
-- │                          PLUGIN CONFIG                               │
-- ╰──────────────────────────────────────────────────────────────────────╯

-- ── Colorscheme ──────────────────────────────────────────────────────────
vim.cmd.colorscheme("gruvbox")

-- ── Lualine ──────────────────────────────────────────────────────────────
require("lualine").setup()

-- ── Bufferline ───────────────────────────────────────────────────────────
local function buf_delete(bufnr)
	vim.cmd("bdelete " .. bufnr)
end

require("bufferline").setup({
	options = {
		close_command = buf_delete,
		right_mouse_command = buf_delete,
		diagnostics = "nvim_lsp",
		always_show_bufferline = true,
		diagnostics_indicator = function(_, _, diag)
			local icons = { Error = " ", Warn = " ", Hint = " ", Info = " " }
			local ret = (diag.error and icons.Error .. diag.error .. " " or "")
				.. (diag.warning and icons.Warn .. diag.warning or "")
			return vim.trim(ret)
		end,
		offsets = {
			{ filetype = "neo-tree", text = "Neo-tree", highlight = "Directory", text_align = "left" },
		},
		get_element_icon = function(opts)
			local ok, devicons = pcall(require, "nvim-web-devicons")
			return ok and devicons.get_icon_by_filetype(opts.filetype) or ""
		end,
	},
})

-- ── Neo-tree ─────────────────────────────────────────────────────────────
require("neo-tree").setup({
	source_selector = { winbar = true },
	filesystem = {
		follow_current_file = { enabled = true },
		filtered_items = { visible = true },
		use_libuv_file_watcher = true,
	},
})

-- ── Blink Completion ─────────────────────────────────────────────────────
require("blink.cmp").setup({
	keymap = { preset = "enter" },
	appearance = { nerd_font_variant = "mono" },
	completion = { documentation = { auto_show = false } },
	sources = { default = { "lsp", "path", "snippets", "buffer" } },
	fuzzy = { implementation = "lua" },
})

-- ── Treesitter ───────────────────────────────────────────────────────────
local ts = require("nvim-treesitter")
ts.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })

-- Auto-install missing parsers
local installed = {}
for _, lang in ipairs(ts.get_installed()) do
	installed[lang] = true
end
local missing = vim.tbl_filter(function(l)
	return not installed[l]
end, TS_PACKAGES)
if #missing > 0 then
	ts.install(missing, { summary = true })
end

-- Treesitter textobjects movement
local function has_textobjects(lang)
	local ok, query = pcall(vim.treesitter.query.get, lang, "textobjects")
	return ok and query ~= nil
end

local ts_move_ok, ts_move = pcall(require, "nvim-treesitter-textobjects.move")
local ts_move_keys = {
	goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
	goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
	goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
	goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
}

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter_setup", { clear = true }),
	callback = function(ev)
		local bufnr = ev.buf
		pcall(vim.treesitter.start, bufnr)
		vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		vim.wo.foldmethod = "expr"
		vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

		local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
		if ts_move_ok and lang and has_textobjects(lang) then
			for method, keymaps in pairs(ts_move_keys) do
				for key, query in pairs(keymaps) do
					vim.keymap.set({ "n", "x", "o" }, key, function()
						ts_move[method](query, "textobjects")
					end, { buffer = bufnr, silent = true, desc = ("TS %s (%s)"):format(method, query) })
				end
			end
		end
	end,
})

-- ── Mini.ai (text objects) ───────────────────────────────────────────────
local ai = require("mini.ai")
ai.setup({
	n_lines = 500,
	custom_textobjects = {
		o = ai.gen_spec.treesitter({
			a = { "@block.outer", "@conditional.outer", "@loop.outer" },
			i = { "@block.inner", "@conditional.inner", "@loop.inner" },
		}),
		f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
		c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
		t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- HTML tags
		d = { "%f[%d]%d+" }, -- digits
		e = { -- word in camelCase/snake_case
			{ "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
			"^().*()$",
		},
		u = ai.gen_spec.function_call(), -- function call
		U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- function call (stricter)
	},
})

-- ── Mini.surround ────────────────────────────────────────────────────────
require("mini.surround").setup({
	mappings = {
		add = "gsa",
		delete = "gsd",
		find = "gsf",
		find_left = "gsF",
		highlight = "gsh",
		replace = "gsr",
		update_n_lines = "gsn",
	},
})

-- ── Yanky & OSC52 clipboard ──────────────────────────────────────────────
local function paste_from_unnamed()
	local lines = vim.split(vim.fn.getreg(""), "\n", { plain = true })
	return { #lines > 0 and lines or { "" }, vim.fn.getregtype(""):sub(1, 1) }
end

vim.g.clipboard = {
	name = "OSC 52",
	copy = {
		["+"] = require("vim.ui.clipboard.osc52").copy("+"),
		["*"] = require("vim.ui.clipboard.osc52").copy("*"),
	},
	paste = {
		["+"] = paste_from_unnamed,
		["*"] = paste_from_unnamed,
	},
}

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		local ev = vim.v.event
		if ev.operator == "y" and ev.regname == "" then
			vim.fn.setreg("+", ev.regcontents, ev.regtype)
		end
	end,
})

require("yanky").setup({ system_clipboard = { sync_with_ring = false } })

-- ── Refjump ──────────────────────────────────────────────────────────────
require("refjump").setup({
	keymaps = { next = "]]", prev = "[[" },
})

-- ── Indent Blankline ─────────────────────────────────────────────────────
require("ibl").setup({
	indent = { char = "|", tab_char = "|" },
	scope = { show_start = false, show_end = false },
	exclude = { filetypes = { "help", "lazy", "mason" } },
})

-- ── Conform (formatting) ─────────────────────────────────────────────────
require("conform").setup({
	format_on_save = { lsp_format = "fallback", timeout_ms = 500 },
	formatters_by_ft = FORMATTERS,
})

require("conform").formatters.typstyle = {
	append_args = { "--wrap-text" },
}

-- ── Lint ─────────────────────────────────────────────────────────────────
local lint = require("lint")

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
	callback = function()
		local ft = vim.bo.filetype
		if LINTERS[ft] then
			for _, linter in ipairs(LINTERS[ft]) do
				lint.try_lint(linter)
			end
		end
	end,
})

-- ── Tiny Inline Diagnostic ───────────────────────────────────────────────
require("tiny-inline-diagnostic").setup({
	preset = "minimal",
	options = { overwrite_events = { "LspAttach", "DiagnosticChanged" } },
})
vim.diagnostic.config({ virtual_text = false })

-- ── Rustaceanvim ─────────────────────────────────────────────────────────
vim.g.rustaceanvim = {
	server = {
		on_attach = function(_, bufnr)
			vim.keymap.set("n", "<leader>cR", function()
				vim.cmd.RustLsp("codeAction")
			end, { desc = "Code Action", buffer = bufnr })
			vim.keymap.set("n", "<leader>dr", function()
				vim.cmd.RustLsp("debuggables")
			end, { desc = "Rust Debuggables", buffer = bufnr })
		end,
		default_settings = {
			["rust-analyzer"] = {
				cargo = {
					allFeatures = true,
					loadOutDirsFromCheck = true,
					buildScripts = { enable = true },
				},
				checkOnSave = true,
				diagnostics = { enable = true },
				procMacro = { enable = true },
				files = {
					exclude = {
						".direnv",
						".git",
						".jj",
						".github",
						".gitlab",
						"bin",
						"node_modules",
						"target",
						"venv",
						".venv",
					},
					watcher = "client",
				},
			},
		},
	},
}

-- ── Crates.nvim ──────────────────────────────────────────────────────────
require("crates").setup({
	lsp = { enabled = true, actions = true, completion = true, hover = true },
	completion = { crates = { enabled = true, max_results = 8, min_chars = 3 } },
})

-- ── Typst Preview ────────────────────────────────────────────────────────
require("typst-preview").setup({ port = 19260 })

-- ── Firenvim ─────────────────────────────────────────────────────────────
vim.g.firenvim_config = {
	localSettings = {
		[".*"] = {
			takeover = "never",
			selector = [=[textarea:not([readonly],[aria-readonly]),div[role="textbox"],[contenteditable="true"]]=],
		},
	},
}
