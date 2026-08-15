return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        -- vim.g.have_nerd_font is true, so which-key uses its own Nerd Font icons.
        keys = {},
      },

      -- Document existing key chains
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>w', group = '[W]orkspace Sessions' },
        { '<leader>o', group = '[O]ther' },
        { '<leader>ob', group = '[B]uffer' },
        { '<leader>n', group = '[N]otifications' },
        { '<leader>g', group = '[G]it' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>d', group = '[D]atabase' },
        { '<leader>D', group = '[D]eno' },
        { '<leader>a', group = '[A]i' },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
