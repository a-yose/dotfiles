return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup {
        install_dir = vim.fn.stdpath 'data' .. '/site',
      }

      require('nvim-treesitter').install {
        'bash',
        'c',
        'css',
        'csv',
        'diff',
        'git_config',
        'git_rebase',
        'gitcommit',
        'gitignore',
        'html',
        'ini',
        'javascript',
        'json',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'scss',
        'sql',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
      }
      -- Filetypes that ALSO keep the legacy regex engine.
      -- Replaces `additional_vim_regex_highlighting`.
      local keep_regex_syntax = { ruby = true, sql = true }

      -- Filetypes where treesitter indent is NOT used.
      -- Replaces `indent.disable`.
      local no_ts_indent = { ruby = true }

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('ts-attach', { clear = true }),
        callback = function(ev)
          local ft = vim.bo[ev.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft

          -- Neovim 0.12: get_parser() returns nil instead of throwing when no
          -- parser exists. This is the guard -- plugin scratch buffers such as
          -- snacks_notif / snacks_dashboard / dbui have filetypes with no
          -- grammar, and vim.treesitter.start() asserts on them.
          if not vim.treesitter.get_parser(ev.buf, lang, { error = false }) then
            return
          end

          vim.treesitter.start(ev.buf, lang)

          if keep_regex_syntax[ft] then
            vim.bo[ev.buf].syntax = 'ON'
          end

          if not no_ts_indent[ft] then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
