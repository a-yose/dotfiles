return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true }, -- Optional
  },
  keys = {
    { '<leader>db', '<cmd>DBUIToggle<cr>', desc = 'Toggle Database UI' },
    { '<leader>du', '<cmd>DBUI<cr>', desc = 'DB UI window' },
    { '<leader>df', '<cmd>DBUIFindBuffer<cr>', desc = '[F]ind and add current buffer' },
  },
  ft = {
    'sql',
    'mysql',
    'plsql',
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_show_database_icon = 1

    -- Connection URLs come from the environment so credentials stay out of git.
    -- Export them from your shell, mise, or direnv -- or put them in a .env and
    -- run `:Dotenv` (vim-dotenv only loads on that command, never automatically).
    --
    --   SUPABASE_LOCAL_DB_URL=postgres://postgres:postgres@localhost:54322/postgres
    --   SUPABASE_CLOUD_DB_URL=postgres://postgres:<password>@db.<project>.supabase.co:5432/postgres
    local dbs = {}
    local function add(name, url)
      if url and url ~= '' then
        table.insert(dbs, { name = name, url = url })
      end
    end
    add('supabase_local', vim.env.SUPABASE_LOCAL_DB_URL)
    add('supabase_cloud', vim.env.SUPABASE_CLOUD_DB_URL)
    vim.g.dbs = dbs
  end,
}
