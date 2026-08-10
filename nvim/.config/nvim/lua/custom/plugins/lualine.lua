return {
  'nvim-lualine/lualine.nvim',
  config = function()
    require('lualine').setup {
      options = {
        globalstatus = true,
        theme = 'dracula',
        ignore_focus = { 'neo-tree', 'dbui' },
      },
      sections = {
        lualine_c = { { 'buffers', mode = 4 } },
      },
      inactive_winbar = {
        lualine_a = {
          { 'filename', path = 1, file_status = true },
        },
        lualine_b = { { 'filetype' } },
        lualine_c = { { 'diagnostics', sources = { 'nvim_diagnostic' } } },
      },
      winbar = {
        lualine_a = {
          { 'filename', path = 1, file_status = true },
        },
        lualine_b = { { 'filetype' } },
        lualine_c = { { 'diagnostics', sources = { 'nvim_diagnostic' } } },
        lualine_x = { { 'lsp_status' } },
      },
      -- tabline = {
      --   lualine_a = { { 'tabs', mode = 2, path = 1, tabs_color = { active = '#fff', inactive = '000' } } },
      -- },
      dependencies = { 'nvim-tree/nvim-web-devicons' },
    }
  end,
}
