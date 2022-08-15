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
-- some plugins misbehave when we do swap files
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.completeopt = 'menuone,noselect'

vim.g.mapleader = ' '

-- basic keymaps
vim.keymap.set({'n','v'}, '<Space>', '<Nop>', {silent=true}) -- since we're using space for leader

-- diagnostics (errors/warnings to be shown)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float) -- opens diag in box (floating)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)


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
Plug('nvim-treesitter/nvim-treesitter') -- language parser engine
Plug('nvim-treesitter/nvim-treesitter-textobjects') -- more text objects
Plug('nvim-telescope/telescope.nvim', {tag = '0.1.0'}) -- fuzzy search thru files
-- cmp: auto-complete/suggestions
Plug('neovim/nvim-lspconfig') -- built-in LSP configurations
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/nvim-cmp')
Plug('onsails/lspkind-nvim')
-- DevExp
Plug('numToStr/Comment.nvim')  -- "gc" to comment visual regions/lines
Plug('lewis6991/gitsigns.nvim') -- add git info to sign columns
Plug('tpope/vim-fugitive') -- git commands in nvim

-- UI & colorscheme
Plug('gruvbox-community/gruvbox')
Plug('nvim-lualine/lualine.nvim') -- fancy status line
Plug('lukas-reineke/indent-blankline.nvim') -- identation lines on blank lines

-- other
Plug('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})

---------
vim.call('plug#end')

-- color, highlighting, UI stuffs
vim.cmd.colorscheme('gruvbox')

-- plugin keymaps
function remap(mode, key_cmd, binded_fn, opts)
  opts = opts or {remap = true}
  return vim.keymap.set(mode, key_cmd, binded_fn, opts)
end
-- Comment.nvim
require('Comment').setup()
-- lukas-reineke/indent-blankline.nvim
require('indent_blankline').setup {
  char = '┊',
  show_trailing_blankline_indent = false,
}
-- telescope
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      }
    }
  }
}
pcall(require('telescope').load_extension, 'fzf')
remap('n', '<C-p>','<cmd>Telescope<cr>', {desc = 'Open Telescope general search'})
remap('n', '<leader>ff',function()
  require('telescope.builtin').find_files()
end, {desc = '[F]ind [F]iles'})
remap('n', '<leader>fg',function()
  require('telescope.builtin').live_grep()
end, {desc = '[F]ind by [G]rep'})
remap('n', '<leader>fb',function()
  require('telescope.builtin').buffers()
end, {desc = '[F]ind existing [B]uffers'})
remap('n', '<leader>fh',function()
  require('telescope.builtin').help_tags()
end, {desc = '[F]ind [H]elp'})
remap('n', '<leader>fd',function()
  require('telescope.builtin').live_grep()
end, {desc = '[F]ind [D]iagnostics'})
-- treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = {'lua', 'typescript', 'rust', 'go', 'python'},
  highlight = {enable = true},
  indent = {enable = true},
  incremental_selection = {
    enable = true,
    keymap = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      node_decremental = '<c-backspace>'
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



