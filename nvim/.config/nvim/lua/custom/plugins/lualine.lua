return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Neovim 0.12 exposes all in-flight progress (LSP, :checkhealth, ...) here.
    -- `lsp_status` below only covers LSP, so this catches the rest -- and it is
    -- what replaces the fidget.nvim spinner.
    local function progress_status()
      return vim.ui.progress_status and vim.ui.progress_status() or ''
    end

    local recording = {
      function()
        local reg = vim.fn.reg_recording()
        return reg ~= '' and ('󰑊 recording @' .. reg) or ''
      end,
      color = { fg = '#ff9e64', gui = 'bold' },
    }

    -- lualine refreshes on CursorMoved/ModeChanged and a 1s timer, none of which
    -- fire reliably the instant recording starts or stops.
    vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
      group = vim.api.nvim_create_augroup('lualine-macro-indicator', { clear = true }),
      desc = 'Refresh lualine so the macro indicator updates immediately',
      callback = function()
        require('lualine').refresh()
      end,
    })

    require('lualine').setup {
      options = {
        -- globalstatus is driven by `vim.o.laststatus = 3` in lua/options.lua
        theme = 'auto',
        ignore_focus = { 'neo-tree', 'dbui' },
      },
      sections = {
        lualine_c = { { 'buffers', mode = 4 } },
        -- lualine_x's defaults are respecified so prepending `recording` doesn't
        -- drop them.
        lualine_x = { recording, 'encoding', 'fileformat', 'filetype' },
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
        lualine_x = { { 'lsp_status' }, { progress_status } },
      },
    }
  end,
}
