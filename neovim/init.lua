-- What: Mono-file nvim configuration file
-- Why: Easy to see through everything without needing to navigate thru files
-- Features:
-- - LSP
-- - Auto-complete (in insert mode: ctrl-space, navigate w/ Tab+S-Tab, confirm: Enter)
-- - cmd: ":Format" to format
-- -  

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
set background=dark
]])
vim.opt.termguicolors = true
vim.opt.cursorline = true
-- some plugins misbehave when we do swap files
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.completeopt = 'menuone,noselect'
vim.opt.clipboard = "unnamedplus"
vim.opt.lazyredraw = true

vim.g.mapleader = ' '

-- basic keymaps
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true }) -- since we're using space for leader
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>)') -- make :terminal escape out

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
Plug('nvim-telescope/telescope-fzf-native.nvim', {['do'] = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=release && cmake --build build --config Release && cmake --install build --prefix build'})
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

-- UI & colorscheme
Plug('gruvbox-community/gruvbox')
Plug('nvim-lualine/lualine.nvim') -- fancy status line
Plug('lukas-reineke/indent-blankline.nvim') -- identation lines on blank lines

-- other
Plug('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
Plug('saadparwaiz1/cmp_luasnip') -- snippet engine
Plug('L3MON4D3/LuaSnip') -- snippet engine

---------
vim.call('plug#end')

-- color, highlighting, UI stuffs
vim.cmd.colorscheme('gruvbox')

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
      fuzzy = true,   -- allow fuzzy matches
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case'
    }
  }
}
pcall(require('telescope').load_extension, 'fzf')
remap('n', '<C-p>', '<cmd>Telescope<cr>', { desc = 'Open Telescope general search' })
remap('n', '<leader>ff', function()
  require('telescope.builtin').find_files()
end, { desc = '[F]ind [F]iles' })
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
