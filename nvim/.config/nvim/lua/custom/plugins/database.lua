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
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_show_database_icon = 1
    vim.g.dbs = {
      { name = 'supabase_local', url = 'postgres://postgres:postgres@localhost:54322/postgres' },
      { name = 'supabase_cloud', url = 'postgres://postgres:[YOUR-CLOUD-PASSWORD]@db.[YOUR-PROJECT-ID].supabase.co:5432/postgres' },
    }
  end,
}
