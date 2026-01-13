return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- 基础配置
      require("fzf-lua").setup({
        winopts = {
          height = 0.7,       -- 窗口高度
          width  = 0.8,       -- 窗口宽度
          preview = { default = "bat" }, -- 预览器（需要 bat）
        },
      })

      local fzf = require("fzf-lua")
      local map = vim.keymap.set

      -- 常用模糊查找快捷键
      map("n", "<leader><leader>", fzf.files, { desc = "FzfLua: Find Files" })
      map("n", "<leader>ff", fzf.files, { desc = "FzfLua: Find Files" })
      map("n", "<leader>fb", fzf.buffers, { desc = "FzfLua: Buffers" })
      map("n", "<leader>fh", fzf.history, { desc = "FzfLua: Command History" })
      map("n", "<leader>fs", fzf.git_status, { desc = "FzfLua: Git Status" })
    end
  }
}
