-- [[ Setting options ]]
-- See `:help vim.o` -- for more options, see `:help option-list`
--
-- NOTE: options that are already Neovim 0.12 defaults are deliberately not set
-- here (autoindent, wrap, completeopt=menu,popup, ...). Check with `nvim --clean`
-- before adding one back.

vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.number = true
vim.o.relativenumber = true
vim.o.smartindent = true
-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'
-- Don't show the mode, since it's already in the status line
vim.o.showmode = false
vim.o.textwidth = 80
vim.o.linebreak = true

-- Global statusline (lualine reads this rather than setting globalstatus itself)
vim.o.laststatus = 3

-- Border for all floating windows: completion menu, docs, diagnostics, LSP hover.
-- Individual plugins no longer set their own. See `:help 'winborder'`.
vim.o.winborder = 'rounded'

-- Fold settings. Buffers with a treesitter parser upgrade to syntax-aware folds
-- in lua/kickstart/plugins/treesitter.lua; this is the fallback for the rest.
vim.o.foldmethod = 'indent'
vim.o.foldlevel = 99
vim.o.foldminlines = 4

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'` and `:help 'listchars'`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Use the Postgres dialect for the legacy SQL syntax engine
vim.g.sql_type_default = 'pgsql'

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 4

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Built-in undo tree (Neovim 0.12), replaces mbbill/undotree
vim.cmd.packadd 'nvim.undotree'
vim.keymap.set('n', '<leader>u', '<Cmd>Undotree<CR>', { desc = 'Undo tree' })

-- vim: ts=2 sts=2 sw=2 et
