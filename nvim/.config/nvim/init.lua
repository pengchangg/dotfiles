-- Neovim Configuration — lazy.nvim
-- Requires: git (for lazy.nvim bootstrap)

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv or not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load modules
require("config.options")
require("config.keymaps")
require("config.lsp")

-- Load plugins (lazy.nvim)
require("lazy").setup("plugins")
