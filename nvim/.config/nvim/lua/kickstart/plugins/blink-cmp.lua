return {
  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- `friendly-snippets` contains a variety of premade snippets.
      -- blink's own snippet source reads these VSCode-style JSON files directly,
      -- so no separate snippet engine is needed.
      'rafamadriz/friendly-snippets',
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- <c-y> accept, <c-space> menu/docs, <c-n>/<c-p> select, <c-e> hide,
        -- <c-k> signature, <tab>/<s-tab> move through snippet tabstops.
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = 'default',
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        -- Borders come from `vim.o.winborder` (see lua/options.lua).
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
        per_filetype = {
          -- sql = { 'snippets', 'dadbod', 'buffer' },
        },
        providers = {
          lsp = {
            enabled = true,
            async = false,
            max_items = 15,
          },
          snippets = {
            max_items = 3,
          },
          lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
          -- dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
        },
      },

      -- Expansion goes through Neovim's native `vim.snippet` (:h vim.snippet).
      snippets = { preset = 'default' },

      -- Rust fuzzy matcher; downloads a prebuilt binary, falls back to Lua with a warning.
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { sorts = {
        'exact',
        'score',
        'sort_text',
        'label',
      }, implementation = 'prefer_rust_with_warning' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
