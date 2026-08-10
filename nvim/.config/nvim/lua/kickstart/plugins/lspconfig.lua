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

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

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

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              ---@diagnostic disable-next-line: param-type-mismatch
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
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
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
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
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
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
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
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
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
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
        markdownlint = {},
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
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'markdownlint',
        'eslint',
        'ts_ls',
        'marksman',
        'postgres_lsp',
        'tailwindcss',
        'cssls',
        'html',
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
