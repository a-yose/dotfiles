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
          -- 'sh' is taken by the window-move mapping in lua/keymaps.lua
          highlight = 'sH',
        },
      }

      require('mini.sessions').setup {
        autoread = false,
        autowrite = true,
        file = 'SessionLocal.vim',
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
      end, { desc = 'Write Session Name' })

      vim.keymap.set('n', '<leader>ww', function()
        MiniSessions.write(MiniSessions.config.file)
      end, { desc = 'Write Local Session' })

      vim.keymap.set('n', '<leader>wD', function()
        local name = vim.fn.input 'Delete Session: '
        MiniSessions.delete(name)
      end, { desc = 'Delete Session by Name' })

      vim.keymap.set('n', '<leader>wL', function()
        -- get_latest() only returns a name; it has to be read to be loaded.
        local latest = MiniSessions.get_latest()
        if latest then
          MiniSessions.read(latest)
        else
          vim.notify('No sessions detected', vim.log.levels.WARN)
        end
      end, { desc = 'Load Latest Session' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
