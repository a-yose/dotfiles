return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    version = false,
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup {
        mappings = {
          --   add = 'ys',
          --   delete = 'ds',
          --   find = '',
          --   find_left = '',
          highlight = 'sH',
          --   replace = 'cs',
          --   update_n_lines = '',
          --
          --   -- Add this only if you don't want to use extended mappings
          --   suffix_last = '',
          --   suffix_next = '',
        },
        -- search_method = 'cover_or_next',
      }

      require('mini.sessions').setup {
        autoread = false,
        autowrite = true,
        file = 'SessionLocal.vim',
        -- hooks = {
        --   pre = {
        --     write = function()
        --       for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        --         local name = vim.api.nvim_buf_get_name(bufnr)
        --         if name ~= '' then
        --           -- If there is *no* extension at end of filename…
        --           if not name:match '%.%w+$' then
        --             -- delete it so mksession won't save it
        --             vim.api.nvim_buf_delete(bufnr, { force = true })
        --           end
        --         end
        --       end
        --     end,
        --   },
        -- },
      }

      vim.keymap.set('n', '<leader>ws', function()
        MiniSessions.select()
      end, { desc = 'Select Session' })

      vim.keymap.set('n', '<leader>wl', function()
        MiniSessions.read()
      end, { desc = 'Select Local Session' })

      vim.keymap.set('n', '<leader>wW', function()
        local name = vim.fn.input 'Session name: '
        MiniSessions.write(name)
      end, {
        desc = 'Write Session Name',
      })

      vim.keymap.set('n', '<leader>ww', function()
        MiniSessions.write()
      end, {
        desc = 'Write Local Session',
      })

      vim.keymap.set('n', '<leader>wg', function()
        print(vim.inspect(MiniSessions.detected))
      end, { desc = 'Get Sessions Table' })

      vim.keymap.set('n', '<leader>wD', function()
        local name = vim.fn.input 'Delete Session: '
        MiniSessions.delete(name)
      end, {
        desc = 'Delete Session by Name',
      })

      vim.keymap.set('n', '<leader>wL', function()
        MiniSessions.get_latest()
      end, { desc = 'Select Latest Session' })

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      -- local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      -- statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      -- statusline.section_location = function()
      --   return '%2l:%-2v'
      -- end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
