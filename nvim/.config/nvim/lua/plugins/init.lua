-- Plugin specifications (lazy.nvim)

return {
  -- Treesitter: better syntax highlighting (deferred loading)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function(_, opts)
      pcall(function()
        require("nvim-treesitter.configs").setup(opts)
      end)
    end,
    opts = {
      ensure_installed = { "lua", "python", "bash", "markdown", "json", "yaml", "toml", "gitignore" },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Telescope: fuzzy finder (files, grep, buffers)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>",   desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",    desc = "Find text" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",      desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",    desc = "Help" },
    },
  },

  -- LSP support
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      -- Mason: LSP installer
      require("mason").setup()

      -- Completion
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
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
    opts = {
      options = {
        theme = "auto",
        icons_enabled = false,  -- no NERD Fonts
        component_separators = "|",
        section_separators = "",
      },
    },
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },

  -- Comment helper (gcc to toggle comment)
  {
    "numToStr/Comment.nvim",
    opts = {},
  },
}
