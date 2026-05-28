-- Plugin configuration (vim.pack — auto-loaded from pack/plugins/start/)

-- Treesitter
pcall(function()
  require("nvim-treesitter.configs").setup({
    ensure_installed = { "lua", "python", "bash", "markdown", "json", "yaml", "toml", "gitignore" },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  })
end)

-- Telescope
pcall(function()
  local telescope = require("telescope")
  telescope.setup({})
  local builtin = require("telescope.builtin")
  vim.keymap.set("n", "<leader>ff", builtin.find_files,   { desc = "Find files" })
  vim.keymap.set("n", "<leader>fg", builtin.live_grep,    { desc = "Find text" })
  vim.keymap.set("n", "<leader>fb", builtin.buffers,      { desc = "Buffers" })
  vim.keymap.set("n", "<leader>fh", builtin.help_tags,    { desc = "Help" })
end)

-- LSP + Mason + Completion
pcall(function()
  require("mason").setup({})
end)

pcall(function()
  local cmp = require("cmp")
  cmp.setup({
    snippet = {
      expand = function(args) require("luasnip").lsp_expand(args.body) end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
    }),
  })
end)

-- Lualine
pcall(function()
  require("lualine").setup({
    options = {
      theme = "auto",
      icons_enabled = false,
      component_separators = "|",
      section_separators = "",
    },
  })
end)

-- Gitsigns
pcall(function()
  require("gitsigns").setup({})
end)

-- Comment
pcall(function()
  require("Comment").setup({})
end)
