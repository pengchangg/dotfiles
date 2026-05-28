-- Neovim Configuration — vim.pack API (Neovim 0.12+)
-- Plugins: git clone into pack/plugins/start/ then :Plugins for config

-- Bootstrap plugins on first run
local packdir = vim.fn.stdpath("data") .. "/site/pack/plugins/start"
if vim.fn.isdirectory(packdir .. "/nvim-treesitter") == 0 then
  local repos = {
    { "nvim-treesitter/nvim-treesitter" },
    { "nvim-telescope/telescope.nvim",     dependencies = { "nvim-lua/plenary.nvim" } },
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "L3MON4D3/LuaSnip" },
    { "nvim-lualine/lualine.nvim",         dependencies = { "nvim-tree/nvim-web-devicons" } },
    { "lewis6991/gitsigns.nvim" },
    { "numToStr/Comment.nvim" },
  }
  vim.fn.mkdir(packdir, "p")
  for _, repo in ipairs(repos) do
    local name = repo[1]:match("/(.+)$")
    local path = packdir .. "/" .. name
    if vim.fn.isdirectory(path) == 0 then
      vim.fn.system({ "git", "clone", "--depth=1",
        "https://github.com/" .. repo[1] .. ".git", path })
    end
    if repo.dependencies then
      for _, dep in ipairs(repo.dependencies) do
        local depname = dep:match("/(.+)$")
        local deppath = packdir .. "/" .. depname
        if vim.fn.isdirectory(deppath) == 0 then
          vim.fn.system({ "git", "clone", "--depth=1",
            "https://github.com/" .. dep .. ".git", deppath })
        end
      end
    end
  end
  vim.cmd("packloadall")
end

-- Load modules
require("config.options")
require("config.keymaps")
require("config.lsp")
require("plugins")
