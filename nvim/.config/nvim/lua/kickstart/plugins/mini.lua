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

      -- TODO: folds do not appear to survive a session round-trip. 'sessionoptions'
      -- does include `folds`, so the first thing to check is that it lacks
      -- `localoptions` -- window-local 'foldmethod'/'foldexpr' (set by ftplugins
      -- and by nvim-treesitter) are therefore not saved, so a restored window
      -- recomputes folds from whatever the defaults are.
      require('mini.sessions').setup {
        autoread = false,
        autowrite = true,
        file = 'SessionLocal.vim',
      }

      -- Named sessions live in one of two stores: a per-project one keyed off
      -- the cwd, and a shared one for sessions that span projects. Only one
      -- can be active at a time, so every mapping points `directory` at the
      -- store it needs before acting. It is deliberately *not* restored
      -- afterwards: `select()` reads `directory` inside its `vim.ui.select`
      -- callback, which fires long after the mapping has returned.
      local global_dir = vim.fn.stdpath 'data' .. '/session'
      local function project_dir()
        return vim.fn.stdpath 'data' .. '/sessions/' .. vim.fn.getcwd():gsub('^/', ''):gsub('/', '%%')
      end

      local function scope(dir)
        vim.fn.mkdir(dir, 'p') -- neither write() nor mksession creates it
        MiniSessions.config.directory = dir
        return dir
      end

      -- Pickers also list the local session, since detection always merges it
      -- in, so the guard has to account for it.
      local function pick(dir, action, opts)
        scope(dir)
        local has_local = vim.fn.filereadable(vim.fn.getcwd() .. '/' .. MiniSessions.config.file) == 1
        if vim.fs.dir(dir)() == nil and not has_local then
          return vim.notify('No sessions in ' .. dir, vim.log.levels.WARN)
        end
        MiniSessions.select(action, opts)
      end

      local function write_named(dir)
        scope(dir)
        local name = vim.fn.input 'Session name: '
        if name ~= '' then
          MiniSessions.write(name)
        end
      end

      -- `force` on delete because it otherwise refuses to remove the currently
      -- active session; picking it out of the list is confirmation enough.
      local del_opts = { force = true }

      -- Save -----------------------------------------------------------------
      vim.keymap.set('n', '<leader>ww', function()
        -- No name means "rewrite whatever is active", at whatever scope that
        -- session lives. With nothing active, fall back to creating the local
        -- one rather than erroring.
        if vim.v.this_session ~= '' then
          MiniSessions.write()
        else
          MiniSessions.write(MiniSessions.config.file)
        end
      end, { desc = 'Save Session' })

      vim.keymap.set('n', '<leader>wi', function()
        -- `v:this_session` is the only record of what is loaded; mini keeps no
        -- separate state. Empty means no session was ever read or written.
        local path = vim.fs.normalize(vim.v.this_session)
        if path == '' then
          return vim.notify('No active session', vim.log.levels.WARN)
        end
        local where = 'global'
        if vim.fn.fnamemodify(path, ':t') == MiniSessions.config.file then
          where = 'local'
        elseif vim.startswith(path, vim.fs.normalize(project_dir())) then
          where = 'project'
        end
        vim.notify(('%s  (%s)\n%s'):format(vim.fn.fnamemodify(path, ':t'), where, path))
      end, { desc = 'Show Current Session' })

      -- Local ----------------------------------------------------------------
      vim.keymap.set('n', '<leader>wl', function()
        -- `read()` with no name falls back to the latest session in the active
        -- store when there is no local one, so check for the file directly.
        -- `detected` is only refreshed on setup/read/write, so it goes stale
        -- after a `:cd`.
        local file = MiniSessions.config.file
        if vim.fn.filereadable(vim.fn.getcwd() .. '/' .. file) == 1 then
          MiniSessions.read(file)
        else
          vim.notify('No local session in ' .. vim.fn.getcwd(), vim.log.levels.WARN)
        end
      end, { desc = 'Local: Read' })

      -- Project --------------------------------------------------------------
      vim.keymap.set('n', '<leader>wp', function()
        pick(project_dir(), 'read')
      end, { desc = 'Project: Read (select)' })

      vim.keymap.set('n', '<leader>wL', function()
        scope(project_dir())
        -- get_latest() only returns a name; it has to be read to be loaded.
        local latest = MiniSessions.get_latest()
        if latest then
          MiniSessions.read(latest)
        else
          vim.notify('No sessions detected', vim.log.levels.WARN)
        end
      end, { desc = 'Project: Read Latest' })

      vim.keymap.set('n', '<leader>wP', function()
        write_named(project_dir())
      end, { desc = 'Project: Write (name)' })

      vim.keymap.set('n', '<leader>wx', function()
        pick(project_dir(), 'delete', del_opts)
      end, { desc = 'Project: Delete (select)' })

      -- Global ---------------------------------------------------------------
      vim.keymap.set('n', '<leader>wg', function()
        pick(global_dir, 'read')
      end, { desc = 'Global: Read (select)' })

      vim.keymap.set('n', '<leader>wG', function()
        write_named(global_dir)
      end, { desc = 'Global: Write (name)' })

      vim.keymap.set('n', '<leader>wX', function()
        pick(global_dir, 'delete', del_opts)
      end, { desc = 'Global: Delete (select)' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
