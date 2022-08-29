-- What: Mono-file nvim configuration file
-- Why: Easy to see through everything without needing to navigate thru files
-- Features:
-- - LSP
-- - Auto-complete (in insert mode: ctrl-space, navigate w/ Tab+S-Tab, confirm: Enter)
-- - cmd: ":Format" to format
-- - Harpoon marks: Navigate through main files within each project

-- Basic settings of vim
vim.cmd([[
set number relativenumber
set tabstop=4 softtabstop=4
set expandtab
set shiftwidth=4
set smartindent
set exrc
set incsearch
set scrolloff=15
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

-- basic keymaps
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true }) -- since we're using space for leader
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>)') -- make :terminal escape out
vim.keymap.set({ 'n', 'i', 'v' }, '<c-l>', '<Cmd>:mode<Cr>') -- redraw on every mode

-- diagnostics (errors/warnings to be shown)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float) -- opens diag in box (floating)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist) -- opens list of diags


-- vim-plug
vim.cmd([[
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
]])

local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.config/nvim/plugged')
-- libs and dependencies
Plug('nvim-lua/plenary.nvim')

-- plugins
Plug('nvim-treesitter/nvim-treesitter') -- language parser engine for highlighting
Plug('nvim-treesitter/nvim-treesitter-textobjects') -- more text objects
Plug('nvim-telescope/telescope.nvim', { tag = '0.1.0' }) -- file browser
Plug('nvim-telescope/telescope-fzf-native.nvim',
  { ['do'] = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=release && cmake --build build --config Release && cmake --install build --prefix build' })
Plug('nvim-telescope/telescope-file-browser.nvim')
-- cmp: auto-complete/suggestions
Plug('neovim/nvim-lspconfig') -- built-in LSP configurations
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/nvim-cmp')
Plug('onsails/lspkind-nvim')
-- DevExp
Plug('numToStr/Comment.nvim') -- "gc" to comment visual regions/lines
Plug('lewis6991/gitsigns.nvim') -- add git info to sign columns
Plug('tpope/vim-fugitive') -- git commands in nvim
Plug('williamboman/mason.nvim') -- LSP, debuggers,... package manager
Plug('williamboman/mason-lspconfig.nvim') -- lsp config for mason
Plug('ThePrimeagen/harpoon') -- 1-click through marked files per project

-- UI & colorscheme
Plug('gruvbox-community/gruvbox')
Plug('nvim-lualine/lualine.nvim') -- fancy status line
Plug('lukas-reineke/indent-blankline.nvim') -- identation lines on blank lines

-- other
Plug('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
Plug('saadparwaiz1/cmp_luasnip') -- snippet engine
Plug('L3MON4D3/LuaSnip') -- snippet engine
Plug('mickael-menu/zk-nvim') -- Zettelkasten

---------
vim.call('plug#end')

-- color, highlighting, UI stuffs
vim.cmd([[ colorscheme gruvbox ]])

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

require('zk').setup({
  picker = "telescope",
  lsp = {
    config = {
      cmd = {"zk", "lsp"},
      name = "zk",
    },
    auto_attach = {
      enabled = true,
      filetypes = {"markdown"},

    },
  }
})

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
end, { desc =  '[F]ind [A]ll files' })

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

-- treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'lua', 'typescript', 'rust', 'go', 'python', 'prisma' },
  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      node_decremental = '<c-backspace>',
      scope_incremental = '<c-S>'
    }
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
harpoon_nav('1',1)
harpoon_nav('2',2)
harpoon_nav('3',3)
harpoon_nav('4',4)
harpoon_nav('5',5)
harpoon_nav('6',6)
harpoon_nav('7',7)
harpoon_nav('8',8)
harpoon_nav('9',9)
harpoon_nav('0',10)

-- LSP settings
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
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

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

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
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ja', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', vim.lsp.buf.format or vim.lsp.buf.formatting,
    { desc = 'Format current buffer with LSP' })
end
-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- default language servers
local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver', 'sumneko_lua', "prisma-language-server" }
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
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
          telemetry = { enable = false }
        }
      }
    }
  end
})

-- nvim-cmp
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
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
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

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
}
