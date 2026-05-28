-- Language, LSP, formatter, and linter lists shared by other modules.

local M = {}

-- ╭──────────────────────────────────────────────────────────────────────╮
-- │                         LANGUAGE CONFIG                              │
-- ╰──────────────────────────────────────────────────────────────────────╯

M.TS_PACKAGES = {
	"bash",
	"cpp",
	"glsl",
	"go",
	"gomod",
	"gosum",
	"gowork",
	"javascript",
	"json5",
	"lua",
	"ninja",
	"nix",
	"python",
	"regex",
	"ron",
	"rst",
	"rust",
	"typescript",
	"typst",
	"yaml",
	"zig",
}

M.LSPS = {
	"basedpyright",
	"clangd",
	"gopls",
	"hls",
	"jsonls",
	"lua_ls",
	"nixd",
	"ruff",
	"tinymist",
	"tombi",
	"ts_ls",
	"yamlls",
	"zls",
}

M.FORMATTERS = {
	html = { "prettier" },
	json = { "prettier" },
	lua = { "stylua" },
	nix = { "nixfmt" },
	python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
	rust = { "rustfmt" },
	sh = { "shfmt" },
	toml = { "tombi" },
	typst = { "typstyle" },
	yaml = { "yamlfmt" },
}

M.LINTERS = {
	go = { "golangcilint" },
	sh = { "shellcheck" },
	toml = { "tombi" },
}

return M
