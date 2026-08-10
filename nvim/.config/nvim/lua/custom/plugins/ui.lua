return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  opts = {
    lsp = {
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
    routes = {
      {
        view = 'notify',
        filter = { event = 'msg_showmode' },
      },
      {
        filter = {
          event = 'notify',
          find = 'No information available',
        },
        opts = { skip = true },
      },
      {
        filter = {
          kind = 'list_cmd',
        },
        view = 'messages',
        opts = {
          enter = true,
        },
      },
    },
  },
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    'MunifTanjim/nui.nvim',
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    -- 'rcarriga/nvim-notify',
  },
}
