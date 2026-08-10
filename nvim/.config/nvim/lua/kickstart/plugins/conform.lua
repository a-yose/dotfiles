return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = function(bufnr)
          local path = vim.api.nvim_buf_get_name(bufnr)
          if path:find('/supabase/functions/', 1, true) then
            return { 'deno_fmt' }
          end
          return { 'prettierd', 'prettier', stop_after_first = true }
        end,
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = function(bufnr)
          local path = vim.api.nvim_buf_get_name(bufnr)
          if path:find('/supabase/functions/', 1, true) then
            return { 'deno_fmt' }
          end
          return { 'prettierd', 'prettier', stop_after_first = true }
        end,
        json = { 'prettierd', 'prettier', stop_after_first = true },
        yaml = { 'prettierd' },
        markdown = { 'prettierd', 'prettier' },
      },
      formatters = {
        -- deno fmt discovers its config (the `fmt` block in deno.json) by
        -- walking up from cwd. Conform's built-in `deno_fmt` doesn't set cwd,
        -- so it inherits Neovim's cwd — which in a hybrid Node/Deno project
        -- is usually the Node root and has no deno.json to find. Anchoring
        -- cwd at the closest deno.json/jsonc ancestor lets deno fmt actually
        -- pick up `singleQuote`, `lineWidth`, etc. from the project config.
        deno_fmt = {
          cwd = function(_, ctx)
            return vim.fs.root(ctx.buf, { 'deno.json', 'deno.jsonc' })
          end,
        },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
