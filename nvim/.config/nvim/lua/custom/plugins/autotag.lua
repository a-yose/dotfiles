-- Auto close/rename HTML & JSX tags.
-- Neovim 0.12 has a native equivalent (vim.lsp.linked_editing_range) but it
-- depends on the server implementing textDocument/linkedEditingRange, which
-- ts_ls does not do reliably for TSX -- hence the plugin.
return {
  'windwp/nvim-ts-autotag',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  ft = {
    'html',
    'xml',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'svelte',
    'vue',
    'markdown',
  },
  -- All settings are already the plugin defaults.
  opts = {},
}
