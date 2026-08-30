-- LSP Plugins
return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        -- snacks.nvim sets the `Snacks` global at runtime; lazydev only pulls in
        -- plugin sources on `require()`, so match the bare global instead.
        { path = 'snacks.nvim', words = { 'Snacks' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      -- Cleared once here rather than inside the LspAttach callback, which would
      -- tear down and rebuild the group on every attach.
      local detach_group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true })

      --  This function gets run when an LSP attaches to a particular buffer.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- Sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- NOTE: `grn` (rename), `gra` (code action), `grx` (codelens), `K` (hover) and
          -- `<C-s>` (signature) are Neovim defaults since 0.11 -- see `:help lsp-defaults`.
          -- The maps below deliberately override the defaults to use Telescope pickers
          -- instead of the built-in quickfix/vim.ui.select UI.

          -- Find references for the word under your cursor.
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          -- Highlight references of the word under the cursor when it rests there
          -- for a little while; cleared again on move.
          --    See `:help CursorHold` for information about when this is executed
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = detach_group,
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        -- Border comes from `vim.o.winborder` (see lua/options.lua).
        float = { source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        -- Truncated inline text everywhere, plus the full message rendered below
        -- the cursor line (`virtual_lines`, Neovim 0.11+).
        virtual_text = { source = 'if_many', spacing = 2 },
        virtual_lines = { current_line = true },
      }

      -- LSP servers and clients communicate to each other what features they support.
      --  blink.cmp adds capabilities beyond Neovim's defaults, so broadcast those.
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Enable the following language servers.
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed
      --  via mason-tool-installer (which reads `vim.tbl_keys(servers)` below) and auto-enabled by
      --  mason-lspconfig (v2.x's `automatic_enable` calls `vim.lsp.enable()` after install).
      --
      --  Add any additional override configuration in the following table. Each entry is passed to
      --  `vim.lsp.config(server_name, ...)`; available keys mirror the LSP config schema:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities (the '*' wildcard below provides
      --        blink.cmp capabilities to every server; this is for per-server tweaks)
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      --  - root_markers (string[]): Filename markers used to discover the project root. Lists
      --        REPLACE upstream defaults (deep-merge replaces arrays wholesale), which is
      --        load-bearing for ts_ls/denols routing: nvim-lspconfig's denols default includes
      --        '.git', so without an explicit override denols would attach to every TS file in a
      --        git repo. See https://docs.deno.com/runtime/getting_started/setup_your_environment/
      local servers = {
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`ts_ls`) will work just fine
        -- ts_ls / denols configured per Deno's official Neovim docs:
        --   https://docs.deno.com/runtime/getting_started/setup_your_environment/#neovim-0.6+-using-the-built-in-language-server
        -- Each gets a distinct root marker so they don't both attach to the
        -- same buffer. ts_ls additionally sets single_file_support = false to
        -- prevent it from running in single-file mode on lone TS files.
        ts_ls = {
          root_markers = { 'package.json' },
          single_file_support = false,
        },
        denols = {
          root_markers = { 'deno.json', 'deno.jsonc' },
        },
        eslint = {
          -- The upstream eslint root_dir (see nvim-lspconfig lsp/eslint.lua)
          -- bails out (no attach) if it finds ANY of deno.json/deno.jsonc/deno.lock
          -- upward from the buffer. This project keeps a stray deno.lock at the
          -- repo root for the supabase edge functions, which disabled eslint
          -- across the whole Node project. Defer to Deno only where Deno actually
          -- roots a project (deno.json/deno.jsonc) -- matching the denols
          -- root_markers above -- and otherwise root eslint at the nearest
          -- eslint config file.
          root_dir = function(bufnr, on_dir)
            if vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' }) then
              return
            end
            local eslint_config_files = {
              '.eslintrc',
              '.eslintrc.js',
              '.eslintrc.cjs',
              '.eslintrc.yaml',
              '.eslintrc.yml',
              '.eslintrc.json',
              'eslint.config.js',
              'eslint.config.mjs',
              'eslint.config.cjs',
              'eslint.config.ts',
              'eslint.config.mts',
              'eslint.config.cts',
            }
            local root = vim.fs.root(bufnr, eslint_config_files)
            if root then
              on_dir(root)
            end
          end,
        },
        jsonls = {},
        cssls = {},
        marksman = {},
        html = {},
        postgres_lsp = {
          -- The previous cmd overrides were malformed (extra positional args
          -- after `lsp-proxy` caused the binary to exit with
          -- "`postgres-language-server` is not expected in this context").
          -- Falling back to lspconfig's default cmd: `{ 'postgres-language-server', 'lsp-proxy' }`.
          --
          -- root_dir handles two cases:
          --   1. Normal SQL files in a project — walks up from the file looking
          --      for postgres-language-server.jsonc (or the legacy
          --      postgrestools.jsonc filename, kept for projects mid-rename).
          --   2. vim-dadbod-ui query buffers — these live under
          --      ~/.local/share/db_ui/ (or are unnamed scratch buffers), so
          --      walking up from the buffer's own file never reaches the
          --      project. Falls back to walking up from cwd, which gives
          --      postgres_lsp the full project config (typecheck, db connection,
          --      pglinter rules) whenever nvim was launched from the project
          --      root.
          root_dir = function(bufnr, on_dir)
            local markers = { 'postgres-language-server.jsonc', 'postgrestools.jsonc' }
            local root = vim.fs.root(bufnr, markers)
            if root then
              return on_dir(root)
            end
            local found = vim.fs.find(markers, { path = vim.fn.getcwd(), upward = true, type = 'file' })[1]
            if found then
              return on_dir(vim.fs.dirname(found))
            end
            on_dir(nil)
          end,
        },
        tailwindcss = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
      }

      -- Every key of `servers` is already included via vim.tbl_keys; only list
      -- tools here that are NOT LSP servers configured above (formatters from
      -- conform.lua, linters from lint.lua) plus servers needing no config.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'bashls', -- LSP, no per-server config needed
        'stylua', -- conform: lua
        'prettierd', -- conform: js/ts/json/yaml/markdown
        'shfmt', -- conform: sh/bash
        'markdownlint', -- nvim-lint: markdown
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- Register per-server config via the native vim.lsp.config() API (Neovim 0.11+).
      -- mason-lspconfig v2.0 removed the `handlers` setup field and now auto-enables
      -- installed servers via vim.lsp.enable() (its `automatic_enable` defaults to true).
      -- We pre-register configs here so they're in place when servers are enabled.
      --
      -- The '*' wildcard provides blink.cmp capabilities to every server; per-server
      -- entries layer on top via deep merge.
      vim.lsp.config('*', { capabilities = capabilities })
      for server_name, server_config in pairs(servers) do
        vim.lsp.config(server_name, server_config)
      end

      ---@diagnostic disable-next-line: missing-fields
      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
