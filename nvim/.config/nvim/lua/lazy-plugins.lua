-- [[ Configure and install plugins ]]
--
--  :Lazy         check plugin status (`?` for help, `:q` to close)
--  :Lazy update  update plugins
require('lazy').setup({
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically

  require 'kickstart.plugins.gitsigns',

  require 'kickstart.plugins.which-key',

  require 'kickstart.plugins.telescope',

  require 'kickstart.plugins.lspconfig',

  require 'kickstart.plugins.conform',

  require 'kickstart.plugins.blink-cmp',

  require 'kickstart.plugins.tokyonight',

  require 'kickstart.plugins.todo-comments',

  require 'kickstart.plugins.mini',

  require 'kickstart.plugins.treesitter',

  require 'kickstart.plugins.debug',
  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',

  -- Everything in lua/custom/plugins/*.lua
  { import = 'custom.plugins' },
}, {
  -- NOTE: this is lazy.nvim's *config* table (second argument). Options here
  -- only take effect in this position -- inside the spec list above they are
  -- silently treated as a plugin spec and do nothing.
  performance = {
    rtp = { reset = false },
  },
  ui = {
    -- vim.g.have_nerd_font is true, so lazy uses its own Nerd Font icons.
    icons = {},
  },
})

-- vim: ts=2 sts=2 sw=2 et
