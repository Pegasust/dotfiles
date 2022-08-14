-- Basic settings of vim
vim.cmd([[
set number relativenumber
set tabstop=4 softtabstop=4
set expandtab
set shiftwidth=4
set smartindent
set exrc
set incsearch
set scrolloff=7
set signcolumn=yes
set colorcolumn=80
set background=light
]])
vim.opt.termguicolors = true

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
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', {tag = '0.1.0'})
Plug('gruvbox-community/gruvbox')
vim.call('plug#end')

vim.cmd.colorscheme('gruvbox')

