-- What: Mono-file nvim configuration file
-- Why: Easy to see through everything without needing to navigate thru files
-- Features:
-- - LSP
-- - Auto-complete (in insert mode: ctrl-space, navigate w/ Tab+S-Tab, confirm: Enter)
-- - <leader>df to format document
-- - Harpoon marks: Navigate through main files within each project
--
-- REQUIREMENTS:
-- - zk  @ https://github.com/mickael-menu/zk
-- - prettierd @ npm install -g @fsouza/prettierd

-- Basic settings of vim
vim.cmd([[
set number relativenumber
set tabstop=4 softtabstop=4
set expandtab
set shiftwidth=4
set smartindent
set exrc
set incsearch
set scrolloff=30
set signcolumn=yes
set colorcolumn=80
set background=light
]])
vim.opt.lazyredraw = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
-- some plugins misbehave when we do swap files
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.completeopt = 'menuone,noselect'
-- vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- basic keymaps
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true }) -- since we're using space for leader
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>)') -- make :terminal escape out
vim.keymap.set({ 'n', 'i', 'v' }, '<c-l>', '<Cmd>:mode<Cr>') -- redraw on every mode

-- diagnostics (errors/warnings to be shown)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float) -- opens diag in box (floating)
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist) -- opens list of diags
-- vim.keymap.set('n', '<leader>wq', vim.diagnostic.setqflist) -- workspace diags
vim.keymap.set('n', '<leader>q', '<cmd>TroubleToggle loclist<cr>')
vim.keymap.set('n', '<leader>wq', '<cmd>TroubleToggle workspace_diagnostics<cr>')


-- vim-plug
local data_dir = vim.fn.stdpath('data')
vim.cmd([[
" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \| PlugInstall --sync | source $MYVIMRC
\| endif
]])

local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.config/nvim/plugged')

-- libs and dependencies
Plug('nvim-lua/plenary.nvim')

-- plugins
Plug('tjdevries/nlua.nvim') -- adds symbols of vim stuffs in init.lua
Plug('nvim-treesitter/nvim-treesitter') -- language parser engine for highlighting
Plug('nvim-treesitter/nvim-treesitter-textobjects') -- more text objects
Plug('nvim-telescope/telescope.nvim', { tag = '0.1.0' }) -- file browser
Plug('nvim-telescope/telescope-fzf-native.nvim',
    { ['do'] = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=release && cmake --build build --config Release && cmake --install build --prefix build' })
Plug('nvim-telescope/telescope-file-browser.nvim')

-- cmp: auto-complete/suggestions
Plug('neovim/nvim-lspconfig') -- built-in LSP configurations
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-cmdline')
Plug('hrsh7th/nvim-cmp')
Plug('onsails/lspkind-nvim')
Plug('yioneko/nvim-yati') -- hopefully fixes Python indentation auto-correct from Tree-sitter
-- Plug('tzachar/cmp-tabnine', { ['do'] = './install.sh' })

-- DevExp
Plug('windwp/nvim-autopairs') -- matches pairs like [] (),...
Plug('windwp/nvim-ts-autotag') -- matches tags <body>hello</body>
Plug('NMAC427/guess-indent.nvim') -- guesses the indentation of an opened buffer
Plug('numToStr/Comment.nvim') -- "gc" to comment visual regions/lines
Plug('lewis6991/gitsigns.nvim') -- add git info to sign columns
Plug('tpope/vim-fugitive') -- git commands in nvim
Plug('williamboman/mason.nvim') -- LSP, debuggers,... package manager
Plug('williamboman/mason-lspconfig.nvim') -- lsp config for mason
Plug('ThePrimeagen/harpoon') -- 1-click through marked files per project
Plug('TimUntersberger/neogit') -- Easy-to-see git status
Plug('folke/trouble.nvim') -- File-grouped workspace diagnostics
Plug('tpope/vim-dispatch') -- Allows quick build/compile/test vim commands
Plug('clojure-vim/vim-jack-in') -- Clojure: ":Boot", ":Clj", ":Lein"
Plug('radenling/vim-dispatch-neovim') -- Add support for neovim's terminal emulator
Plug('Olical/conjure') -- REPL on the source for Clojure (and other LISPs)
Plug('gennaro-tedesco/nvim-jqx') -- JSON formatter (use :Jqx*)
Plug('kylechui/nvim-surround') -- surrounds with tags/parenthesis
Plug('simrat39/rust-tools.nvim') -- config rust-analyzer and nvim integration

-- UI & colorscheme
Plug('gruvbox-community/gruvbox') -- theme provider
Plug('nvim-lualine/lualine.nvim') -- fancy status line
Plug('lukas-reineke/indent-blankline.nvim') -- identation lines on blank lines
Plug('sunjon/shade.nvim') -- make inactive panes have lower opacity
Plug('kyazdani42/nvim-web-devicons') -- icons for folder and filetypes
Plug('m-demare/hlargs.nvim') -- highlights arguments; great for func prog
Plug('folke/todo-comments.nvim') -- Highlights TODO

-- other utilities
Plug('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
Plug('saadparwaiz1/cmp_luasnip') -- snippet engine
Plug('L3MON4D3/LuaSnip') -- snippet engine
Plug('mickael-menu/zk-nvim') -- Zettelkasten

---------
vim.call('plug#end')

-- color, highlighting, UI stuffs
vim.cmd([[ colorscheme gruvbox ]])
require('hlargs').setup()
require('shade').setup {
    overlay_opacity = 60,
    opacity_step = 1,
    keys = {
        brightness_up = '<C-Up>',
        brightness_down = '<C-Down>',
        toggle = '<Leader>s', -- s: sha
    }
}
require('nvim-web-devicons').setup()
require('trouble').setup()
require('todo-comments').setup()

-- plugin keymaps

local function remap(mode, key_cmd, binded_fn, opts)
    opts = opts or { remap = true }
    return vim.keymap.set(mode, key_cmd, binded_fn, opts)
end

-- Comment.nvim
require('Comment').setup()
-- lukas-reineke/indent-blankline.nvim
vim.opt.list = true
vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append "eol:↴"

require("indent_blankline").setup {
    show_end_of_line = true,
    space_char_blankline = " ",
}
-- User command that transform into 2-spaces by translating to tabstop
vim.api.nvim_create_user_command(
    'HalfSpaces',
    function(opts)
        vim.api.nvim_command("set ts=2 sts=2 noet")
        vim.api.nvim_command("retab!")
        vim.api.nvim_command("set ts=1 sts=1 et")
        vim.api.nvim_command("retab")
        vim.api.nvim_command("GuessIndent")
    end,
    { nargs = 0 }
)
vim.api.nvim_create_user_command(
    'DoubleSpaces',
    function(opts)
        -- cannot really do 1-space tab. The minimum is 2-space to begin
        -- doubling
        vim.api.nvim_command("set ts=2 sts=2 noet")
        vim.api.nvim_command("retab!")
        vim.api.nvim_command("set ts=4 sts=4 et")
        vim.api.nvim_command("retab")
        vim.api.nvim_command("GuessIndent")
    end,
    { nargs = 0 }
)

-- telescope
local fb_actions = require "telescope".extensions.file_browser.actions
require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
            },
        },
    },
    extensions = {
        fzf = {
            fuzzy = true, -- allow fuzzy matches
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case'
        },
        file_browser = {
            theme = "ivy",
            hiject_netrw = true, -- disables netrw and use file-browser instead
            mappings = {
                ["i"] = {}, -- disable any shortcut in insert mode for now
                ["n"] = {
                    ["c"] = fb_actions.create,
                    ["r"] = fb_actions.rename,
                    ["m"] = fb_actions.move,
                    ["y"] = fb_actions.copy,
                    ["d"] = fb_actions.remove,
                    ["o"] = fb_actions.open,
                    ["g"] = fb_actions.goto_parent_dir,
                    ["e"] = fb_actions.goto_home_dir,
                    ["w"] = fb_actions.goto_cwd,
                    ["t"] = fb_actions.change_cwd,
                    ["f"] = fb_actions.toggle_browser,
                    ["h"] = fb_actions.toggle_hidden,
                    ["s"] = fb_actions.toggle_all,
                }
            }
        }
    }
}

-- Telescope key remap stuffs
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'file_browser')
remap('n', '<C-p>', '<cmd>Telescope<cr>', { desc = 'Open Telescope general search' })

remap('n', '<leader>fm', function()
    require("telescope").extensions.file_browser.file_browser()
end, { desc = '[F]ile [M]utation' })

remap('n', '<leader>ff', function()
    require('telescope.builtin').find_files({
        hidden = false,
        no_ignore = false,
        follow = false,
    })
end, { desc = '[F]ind [F]ile' })

remap('n', '<leader>fa', function()
    require('telescope.builtin').find_files({
        hidden = true,
        no_ignore = true,
        follow = true,
    })
end, { desc = '[F]ind [A]ll files' })

remap('n', '<leader>fg', function()
    require('telescope.builtin').live_grep()
end, { desc = '[F]ind by [G]rep' })

remap('n', '<leader>fb', function()
    require('telescope.builtin').buffers()
end, { desc = '[F]ind existing [B]uffers' })

remap('n', '<leader>fh', function()
    require('telescope.builtin').help_tags()
end, { desc = '[F]ind [H]elp' })

remap('n', '<leader>fd', function()
    require('telescope.builtin').diagnostics()
end, { desc = '[F]ind [D]iagnostics' })

-- ZK remap stuffs
remap('n', '<leader>zf', function()
    vim.cmd([[:ZkNotes]])
end, { desc = '[Z]ettelkasten [F]iles' })

remap('n', '<leader>zg', function()
    vim.cmd([[:ZkGrep]])
end, { desc = '[Z]ettelkasten [G]rep' })

-- treesitter
require('nvim-treesitter.configs').setup {
    yati = { enable = true, default_lazy = true },
    ensure_installed = {
        'tsx', 'toml', 'lua', 'typescript', 'rust', 'go', 'yaml', 'json', 'php', 'css',
        'python', 'prisma', 'html', "dockerfile", "c", "cpp", "hcl", "svelte", "astro",
        "clojure", "fennel", "bash", "nix"
    },
    sync_install = false,
    highlight = { enable = true },
    indent = { enable = false },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<C-space>',
            node_incremental = '<C-space>',
            node_decremental = '<C-backspace>',
            pscope_incremental = '<C-S>'
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
            },
        },
    },
    -- automatically close and modify HTML and TSX tags
    autotag = {
        enable = true,
    },
}

require('nvim-autopairs').setup {
    check_ts = true,

}

local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
parser_config.astro.filetype_to_parsername = { "javascript", "typescript.tsx", "astro" }


require('guess-indent').setup {
    auto_cmd = true, -- Set to false to disable automatic execution
    filetype_exclude = { -- A list of filetypes for which the auto command gets disabled
        "netrw",
        "tutor",
    },

    buftype_exclude = { -- A list of buffer types for which the auto command gets disabled
        "help",
        "nofile",
        "terminal",
        -- "prompt",
    },
}

-- harpoon: mark significant files & switch between them
remap('n', '<leader>m', function() require('harpoon.mark').add_file() end)
local function harpoon_nav(key, nav_file_index, lead_keybind)
    lead_keybind = lead_keybind or '<leader>h'
    assert(type(key) == "string", "expect key to be string(keybind)")
    assert(type(nav_file_index) == "number" and nav_file_index >= 1, "expect 1-indexed number for file index")
    return remap('n', lead_keybind .. key, function() require('harpoon.ui').nav_file(nav_file_index) end)
end

-- remap letters to index. Inspired by alternating number of Dvorak programmer
-- best practices: try to keep marked files to be around 4
harpoon_nav('f', 1)
harpoon_nav('j', 2)
harpoon_nav('d', 3)
harpoon_nav('k', 4)
remap('n', '<leader>hh', function() require('harpoon.ui').toggle_quick_menu() end)
-- harpoon: navigate by numbers
harpoon_nav('1', 1)
harpoon_nav('2', 2)
harpoon_nav('3', 3)
harpoon_nav('4', 4)
harpoon_nav('5', 5)
harpoon_nav('6', 6)
harpoon_nav('7', 7)
harpoon_nav('8', 8)
harpoon_nav('9', 9)
harpoon_nav('0', 10)

-- neogit: easy-to-see git status
require('neogit').setup {}
remap('n', '<leader>gs', function() require('neogit').open({}) end);

-- LSP settings
-- This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_client, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { noremap = true, buffer = bufnr, desc = desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    nmap('<leader>df', function() vim.lsp.buf.format({ async = true }) end, '[D]ocument [F]ormat')

    -- symbols and gotos
    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('gr', require('telescope.builtin').lsp_references)
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- documentations. See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('gtd', vim.lsp.buf.type_definition, '[G]oto [T]ype [D]efinition')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

end
-- nvim-cmp
local cmp = require 'cmp'
local luasnip = require 'luasnip'
local lspkind = require('lspkind')
local source_mapping = {
    buffer = '[Buffer]',
    nvim_lsp = '[LSP]',
    nvim_lua = '[Lua]',
    -- cmp_tabnine = '[T9]',
    path = '[Path]',
}

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    },
    formatting = {
        format = function(entry, vim_item)
            vim_item.kind = lspkind.symbolic(vim_item.kind, { mode = 'symbol' })
            vim_item.menu = source_mapping[entry.source_name]
            -- if entry.source.name == "cmp_tabnine" then
            --  local detail = (entry.completion_item.data or {}).detail
            --  vim_item.kind = ""
            --  if detail and detail:find('.*%%.*') then
            --   vim_item.kind = vim_item.kind .. ' ' .. detail
            --  end
            --
            --  if (entry.completion_item.data or {}).multiline then
            --   vim_item.kind = vim_item.kind .. ' ' .. '[ML]'
            --  end
            -- end
            local maxwidth = 80
            vim_item.abbr = string.sub(vim_item.abbr, 1, maxwidth)
            return vim_item
        end,
    },
    sources = cmp.config.sources {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        -- { name = 'cmp_tabnine' },
    },
}
-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- local tabnine = require('cmp_tabnine.config')
-- tabnine.setup({
--  max_lines = 1000,
--  max_num_results = 20,
--  sort = true,
--  run_on_every_keystroke = true,
--  snippet_placeholder = '..',
--  ignored_file_types = {},
--  show_prediction_strength = true,
-- })
-- default language servers
local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver', 'sumneko_lua', 'cmake', 'tailwindcss', 'prismals',
    'rnix', 'eslint', 'terraformls', 'tflint', 'svelte', 'astro', 'clojure_lsp', "bashls", 'yamlls', "pylsp" }
require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        },
        check_outdated_packages_on_open = true,
    }
})
require('mason-lspconfig').setup({
    ensure_installed = servers,
    automatic_installation = true
})
require('mason-lspconfig').setup_handlers({
    -- default handler
    function(server_name)
        require('lspconfig')[server_name].setup {
            on_attach = on_attach,
            capabilities = capabilities,
        }
    end,
    ["sumneko_lua"] = function()
        require('lspconfig').sumneko_lua.setup {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = {
                        version = "LuaJIT",
                        path = vim.split(package.path, ";"),
                    },
                    diagnostics = {
                        globals = { "vim" }
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file('', true)
                    },
                    telemetry = { enable = false },
                    format = {
                        enable = true,
                        defaultConfig = {
                            indent_style = "space",
                            indent_size = 4,
                        }
                    }
                }
            }
        }
    end,
    ["tsserver"] = function()
        require('lspconfig').tsserver.setup {
            on_attach = on_attach,
            capabilities = capabilities,
            -- Monorepo support: spawn one instance of lsp within the git
            -- repos.
            root_dir = require('lspconfig.util').root_pattern('.git')
        }
    end,
    -- ["rust_analyzer"] = function()
    --   require('lspconfig').rust_analyzer.setup {
    --       on_attach = on_attach,
    --       capabilities = capabilities,
    --       settings = {
    --           checkOnSave = {
    --               command = "clippy",
    --           }
    --       }
    --   }
    -- end,
    -- ["astro"] = function()
    --  print('configuring astro')
    --  require('lspconfig').astro.setup {
    --   on_attach = on_attach,
    --   capabilities = capabilities,
    --   init_options = {
    --      configuration = {},
    --      typescript = {
    --       serverPath = data_dir
    --      }
    --   }
    --  }
    -- end
})
require("rust-tools").setup {
    tools = { -- rust-tools options

        -- how to execute terminal commands
        -- options right now: termopen / quickfix
        executor = require("rust-tools/executors").termopen,

        -- callback to execute once rust-analyzer is done initializing the workspace
        -- The callback receives one parameter indicating the `health` of the server: "ok" | "warning" | "error"
        on_initialized = nil,

        -- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
        reload_workspace_from_cargo_toml = true,

        -- These apply to the default RustSetInlayHints command
        inlay_hints = {
            -- automatically set inlay hints (type hints)
            -- default: true
            auto = true,

            -- Only show inlay hints for the current line
            only_current_line = false,

            -- whether to show parameter hints with the inlay hints or not
            -- default: true
            show_parameter_hints = true,

            -- prefix for parameter hints
            -- default: "<-"
            parameter_hints_prefix = "<- ",

            -- prefix for all the other hints (type, chaining)
            -- default: "=>"
            other_hints_prefix = "=> ",

            -- whether to align to the length of the longest line in the file
            max_len_align = false,

            -- padding from the left if max_len_align is true
            max_len_align_padding = 1,

            -- whether to align to the extreme right or not
            right_align = false,

            -- padding from the right if right_align is true
            right_align_padding = 7,

            -- The color of the hints
            highlight = "Comment",
        },

        -- options same as lsp hover / vim.lsp.util.open_floating_preview()
        hover_actions = {

            -- the border that is used for the hover window
            -- see vim.api.nvim_open_win()
            border = {
                { "╭", "FloatBorder" },
                { "─", "FloatBorder" },
                { "╮", "FloatBorder" },
                { "│", "FloatBorder" },
                { "╯", "FloatBorder" },
                { "─", "FloatBorder" },
                { "╰", "FloatBorder" },
                { "│", "FloatBorder" },
            },

            -- whether the hover action window gets automatically focused
            -- default: false
            auto_focus = false,
        },

        -- settings for showing the crate graph based on graphviz and the dot
        -- command
        crate_graph = {
            -- Backend used for displaying the graph
            -- see: https://graphviz.org/docs/outputs/
            -- default: x11
            backend = "x11",
            -- where to store the output, nil for no output stored (relative
            -- path from pwd)
            -- default: nil
            output = nil,
            -- true for all crates.io and external crates, false only the local
            -- crates
            -- default: true
            full = true,

            -- List of backends found on: https://graphviz.org/docs/outputs/
            -- Is used for input validation and autocompletion
            -- Last updated: 2021-08-26
            enabled_graphviz_backends = {
                "bmp",
                "cgimage",
                "canon",
                "dot",
                "gv",
                "xdot",
                "xdot1.2",
                "xdot1.4",
                "eps",
                "exr",
                "fig",
                "gd",
                "gd2",
                "gif",
                "gtk",
                "ico",
                "cmap",
                "ismap",
                "imap",
                "cmapx",
                "imap_np",
                "cmapx_np",
                "jpg",
                "jpeg",
                "jpe",
                "jp2",
                "json",
                "json0",
                "dot_json",
                "xdot_json",
                "pdf",
                "pic",
                "pct",
                "pict",
                "plain",
                "plain-ext",
                "png",
                "pov",
                "ps",
                "ps2",
                "psd",
                "sgi",
                "svg",
                "svgz",
                "tga",
                "tiff",
                "tif",
                "tk",
                "vml",
                "vmlz",
                "wbmp",
                "webp",
                "xlib",
                "x11",
            },
        },
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
    server = {
        -- standalone file support
        -- setting it to false may improve startup time
        standalone = true,
        on_attach = function(client, bufnr)
            local nmap = function(keys, func, desc)
                if desc then
                    desc = 'LSP: ' .. desc
                end

                vim.keymap.set('n', keys, func, { noremap = true, buffer = bufnr, desc = desc })
            end
            on_attach(client, bufnr);
            nmap('K', require 'rust-tools'.hover_actions.hover_actions, 'Hover Documentation')

        end,
        capabilities = capabilities,
        settings = {
            checkOnSave = {
                command = "clippy",
            }
        }

    }, -- rust-analyzer options

    -- debugging stuff
    dap = {
        adapter = {
            type = "executable",
            command = "lldb-vscode",
            name = "rt_lldb",
        },
    },
}

require('zk').setup({
    picker = "telescope",
    lsp = {
        config = {
            cmd = { "zk", "lsp" },
            name = "zk",
            on_attach = on_attach,
        },
        auto_attach = {
            enable = true,
            filetypes = { "markdown" }
        },
    },
})

-- Custom ZkOrphans that determines unlinked notes
-- `:ZkOrphans {tags = {"work"}}`
require('zk.commands').add("ZkOrphans", function(options)
    options = vim.tbl_extend("force", { orphan = true }, options or {})
    -- zk.edit opens notes picker
    require('zk').edit(options, { title = "Zk Orphans (unlinked notes)" })
end)
-- ZkGrep: opens file picker
-- In the case where `match_ctor` is falsy, create a prompt.
-- This is so that we distinguish between ZkGrep and ZkNotes
-- Params:
-- match_ctor: string | {match= :string,...} | "" | nil
require('zk.commands').add("ZkGrep", function(match_ctor)
    -- handle polymorphic `match_ctor`
    local grep_str = match_ctor
    local match
    if match_ctor == nil or match_ctor == '' then
        vim.fn.inputsave()
        grep_str = vim.fn.input('Grep string: >')
        vim.fn.inputrestore()
        match = { match = grep_str }
    elseif type(match_ctor) == 'string' then
        match = { match = grep_str }
    end
    require('zk').edit(match, { title = "Grep: '" .. grep_str .. "'" })
end)


-- Gitsigns
require('gitsigns').setup {
    signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
    }
}
require('lualine').setup {
    options = {
        icons_enabled = true,
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
            { 'filename',
                file_status = true,
                newfile_status = false,
                path = 1,
                symbols = {
                    modified = '[+]',
                    readonly = '[-]',
                    unnamed = '[Unnamed]',
                    newfile = '[New]',
                },
            },
        },
        lualine_x = { 'encoding', 'fileformat', 'filetype', },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1, file_status = true, }, },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
    }
}

require('nvim-surround').setup {}

vim.cmd([[
let g:conjure#mapping#doc_word = v:false
]])
