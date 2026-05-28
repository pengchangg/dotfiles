-- Built-in Neovim LSP configuration.

local language = require("config.languages")
local LSPS = language.LSPS

-- ╭──────────────────────────────────────────────────────────────────────╮
-- │                            LSP CONFIG                                │
-- ╰──────────────────────────────────────────────────────────────────────╯

-- Global LSP settings
vim.lsp.config("*", {
	capabilities = { textDocument = { semanticTokens = { multilineTokenSupport = true } } },
	root_markers = { ".git" },
})

-- ── Per-server configs ───────────────────────────────────────────────────

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("tinymist", {
	settings = { formatterMode = "typstyle" },
})

vim.lsp.config("jsonls", {
	settings = {
		json = {
			format = { enable = true },
			validate = { enable = true },
		},
	},
})

vim.lsp.config("gopls", {
	settings = {
		gopls = {
			gofumpt = true,
			codelenses = {
				gc_details = false,
				generate = true,
				regenerate_cgo = true,
				run_govulncheck = true,
				test = true,
				tidy = true,
				upgrade_dependency = true,
				vendor = true,
			},
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
			analyses = {
				nilness = true,
				unusedparams = true,
				unusedwrite = true,
				useany = true,
			},
			usePlaceholders = true,
			completeUnimported = true,
			staticcheck = true,
			directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
			semanticTokens = true,
		},
	},
})

-- ── LSP attach handler ───────────────────────────────────────────────────

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("LspSetup", { clear = true }),
	callback = function(ev)
		local bufnr = ev.buf
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		-- Enable inlay hints if supported
		if client and client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end

		-- Buffer-local keymaps
		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
		end

		map("n", "K", vim.lsp.buf.hover, "LSP Hover")
		map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
		map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
		map("n", "gr", vim.lsp.buf.references, "List References")
		map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
		map("n", "gt", vim.lsp.buf.type_definition, "Type Definition")
		map("n", "<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
		map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
	end,
})

-- Enable all LSP servers
for _, lsp in ipairs(LSPS) do
	vim.lsp.enable(lsp)
end
