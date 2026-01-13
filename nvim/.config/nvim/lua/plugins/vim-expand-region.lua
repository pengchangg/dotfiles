return {
    {
      'terryma/vim-expand-region',
      config = function()
        -- 可选：映射 Ctrl+w 为扩展选择
        vim.api.nvim_set_keymap('v', '<C-w>', '<Plug>(expand_region_expand)', {})
        vim.api.nvim_set_keymap('v', '<C-e>', '<Plug>(expand_region_shrink)', {})
        -- 在普通模式也可以映射
        vim.api.nvim_set_keymap('n', '<C-w>', '<Plug>(expand_region_expand)', {})
      end
    }
}
