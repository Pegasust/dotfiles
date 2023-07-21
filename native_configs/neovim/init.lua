-- What: Mono-file nvim configuration file Why: Easy to see through everything without needing to navigate thru files Features: - LSP
-- - Auto-complete (in insert mode: ctrl-space, navigate w/ Tab+S-Tab, confirm: Enter)
-- - <leader>df to format document
-- - Harpoon marks: Navigate through main files within each project
--

-- Auto-installs vim-plug
vim.cmd([[
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
let plug_path = data_dir . '/autoload/plug.vim'
if empty(glob(plug_path))
  execute '!curl -fLo '.plug_path.' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  execute 'so '.plug_path
endif
]])

-- vim-plug
local Plug = vim.fn['plug#']

-- prepare a list of installed plugins from rtp
local installed_plugins = {}
-- NOTE: nvim_list_runtime_paths will expand wildcard paths for us.
for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
  local last_folder_start = path:find("/[^/]*$")
  if last_folder_start then
    local plugin_name = path:sub(last_folder_start + 1)
    installed_plugins[plugin_name] = true
  end
end

local wplug_log = require('plenary.log').new({ plugin = 'wplug_log', level = 'debug', use_console = false })
-- Do Plug if plugin not yet linked in `rtp`. This takes care of Nix-compatibility
local function WPlug(plugin_path, ...)
  local plugin_name = string.lower(plugin_path:match("/([^/]+)$"))
  if not installed_plugins[plugin_name] then
    wplug_log.info("Plugging " .. plugin_path)
    Plug(plugin_path, ...)
  end
end

vim.call('plug#begin')

-- libs and dependencies
WPlug('nvim-lua/plenary.nvim') -- The base of all plugins
WPlug('MunifTanjim/nui.nvim')  -- For some .so or .dylib neovim UI action


-- plugins
WPlug('tjdevries/nlua.nvim')                                 -- adds symbols of vim stuffs in init.lua
WPlug('nvim-treesitter/nvim-treesitter')                     -- language parser engine for highlighting
WPlug('nvim-treesitter/nvim-treesitter-textobjects')         -- more text objects
WPlug('nvim-telescope/telescope.nvim', { branch = '0.1.x' }) -- file browser
-- TODO: this might need to be taken extra care in our Nix config
-- What this WPlug declaration means is this repo needs to be built on our running environment
-- -----
-- What to do:
-- - Run `make` at anytime before Nix is done on this repository
--  - Might mean that we fetch this repository, run make, and copy to destination folder
-- - Make sure that if we run `make` at first WPlug run, that `make` is idempotent
-- OR
--  Make sure that WPlug does not run `make` and use the output it needs
WPlug('nvim-telescope/telescope-fzf-native.nvim',
  { ['do'] = 'make >> /tmp/log 2>&1' })
WPlug('nvim-telescope/telescope-file-browser.nvim')

-- cmp: auto-complete/suggestions
WPlug('neovim/nvim-lspconfig') -- built-in LSP configurations
WPlug('hrsh7th/cmp-nvim-lsp')
WPlug('hrsh7th/cmp-path')
WPlug('hrsh7th/cmp-buffer') -- Recommends words within the buffer
WPlug('hrsh7th/cmp-cmdline')
WPlug('hrsh7th/nvim-cmp')
WPlug('hrsh7th/cmp-nvim-lsp-signature-help')
WPlug('onsails/lspkind-nvim')
WPlug('yioneko/nvim-yati', { tag = '*' }) -- copium: fix Python indent auto-correct from smart-indent
WPlug('nathanalderson/yang.vim')
-- WPlug('tzachar/cmp-tabnine', { ['do'] = './install.sh' })

-- DevExp
WPlug('windwp/nvim-autopairs')             -- matches pairs like [] (),...
WPlug('windwp/nvim-ts-autotag')            -- matches tags <body>hello</body>
WPlug('NMAC427/guess-indent.nvim')         -- guesses the indentation of an opened buffer
WPlug('j-hui/fidget.nvim')                 -- Progress bar for LSP
WPlug('numToStr/Comment.nvim')             -- "gc" to comment visual regions/lines
WPlug('lewis6991/gitsigns.nvim')           -- add git info to sign columns
WPlug('tpope/vim-fugitive')                -- git commands in nvim
WPlug('williamboman/mason.nvim')           -- LSP, debuggers,... package manager
WPlug('williamboman/mason-lspconfig.nvim') -- lsp config for mason
WPlug('ThePrimeagen/harpoon')              -- 1-click through marked files per project
WPlug('TimUntersberger/neogit')            -- Easy-to-see git status
WPlug('folke/trouble.nvim')                -- File-grouped workspace diagnostics
WPlug('tpope/vim-dispatch')                -- Allows quick build/compile/test vim commands
WPlug('clojure-vim/vim-jack-in')           -- Clojure: ":Boot", ":Clj", ":Lein"
WPlug('radenling/vim-dispatch-neovim')     -- Add support for neovim's terminal emulator
-- WPlug('Olical/conjure')          -- REPL on the source for Clojure (and other LISPs)
WPlug('gennaro-tedesco/nvim-jqx')          -- JSON formatter (use :Jqx*)
WPlug('kylechui/nvim-surround')            -- surrounds with tags/parenthesis
WPlug('simrat39/rust-tools.nvim')          -- config rust-analyzer and nvim integration
WPlug('tjdevries/sg.nvim')                 -- Cody and other cool sourcegraph stuffs

-- UI & colorscheme
WPlug('simrat39/inlay-hints.nvim')              -- type-hints with pseudo-virtual texts
WPlug('gruvbox-community/gruvbox')              -- theme provider
WPlug('nvim-lualine/lualine.nvim')              -- fancy status line
WPlug('lukas-reineke/indent-blankline.nvim')    -- identation lines on blank lines
WPlug('kyazdani42/nvim-web-devicons')           -- icons for folder and filetypes
WPlug('m-demare/hlargs.nvim')                   -- highlights arguments; great for func prog
WPlug('folke/todo-comments.nvim')               -- Highlights TODO
WPlug('NvChad/nvim-colorizer.lua')              -- color highlighter with tailwind support
WPlug('roobert/tailwindcss-colorizer-cmp.nvim') -- color for tailiwnd for compe

-- other utilities
WPlug('nvim-treesitter/nvim-treesitter-context') -- Top one-liner context of func/class scope
WPlug('nvim-treesitter/playground')              -- Sees Treesitter AST - less hair pulling, more PRs
WPlug('saadparwaiz1/cmp_luasnip')                -- snippet engine
WPlug('L3MON4D3/LuaSnip')                        -- snippet engine
WPlug('folke/neodev.nvim')                       -- Neovim + lua development setup
-- Switch cases:
-- `gsp` -> PascalCase (classes), `gsc` -> camelCase (Java), `gs_` -> snake_case (C/C++/Rust)
-- `gsu` -> UPPER_CASE (CONSTs), `gsk` -> kebab-case (Clojure), `gsK` -> Title-Kebab-Case
-- `gs.` -> dot.case (R)
WPlug('arthurxavierx/vim-caser') -- switch cases

---------
vim.call('plug#end')

local PLUGIN_URI = 'gh:pegasust:dotfiles'
local PLUGIN_LEVEL = 'debug'
local log = require('plenary.log').new({ plugin = PLUGIN_URI, level = PLUGIN_LEVEL, use_console = false })

vim.cmd([[
if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  PlugInstall --sync | autocmd VimEnter * so $MYVIMRC
endif
]])

-- special terminals, place them at 4..=7 for ergonomics
-- NOTE: this requires a flawless startup, otherwise, it's going to throw errors
-- since we're basically simulating keystrokes
-- TODO: The correct behavior is to register terminal keystroke with an assigned
-- buffer
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function()
    local function named_term(term_idx, term_name)
      require('harpoon.term').gotoTerminal(term_idx)
      vim.cmd([[:exe ":file ]] .. term_name .. [[" | :bfirst]])
    end

    -- term:ctl at 4
    named_term(4, "term:ctl")
    -- term:dev at 5
    named_term(5, "term:dev")
    -- term:repl at 7
    named_term(7, "term:repl")
    -- term:repl at 6
    named_term(6, "term:repl2")
  end
})

vim.g.gruvbox_contrast_dark = "soft";
vim.g.gruvbox_contrast_light = "soft";
vim.opt.ignorecase = true;
vim.opt.smartcase = true;
vim.opt.incsearch = true;
vim.opt.number = true;
vim.opt.relativenumber = true;
vim.opt.autoindent = true;
vim.opt.smartindent = true;
vim.opt.expandtab = true;
vim.opt.exrc = true;

vim.opt.tabstop = 4;
vim.opt.softtabstop = 4;
vim.opt.shiftwidth = 4;
vim.opt.scrolloff = 30;
vim.opt.signcolumn = "yes";
vim.opt.colorcolumn = "80";

vim.opt.background = "dark";

vim.api.nvim_create_user_command('Dark', function(opts)
    -- opts: {name, args: str, fargs: Splited<str>, range, ...}
    ---@type string
    local contrast = (opts.args and string.len(opts.args) > 0) and opts.args or vim.g.gruvbox_contrast_dark;
    vim.g.gruvbox_contrast_dark = contrast;
    vim.opt.background = "dark";
  end,
  { nargs = "?", })

vim.api.nvim_create_user_command('Light', function(opts)
    -- opts: {name, args: str, fargs: Splited<str>, range, ...}
    ---@type string
    local contrast = (opts.args and string.len(opts.args) > 0) and opts.args or vim.g.gruvbox_contrast_light;
    vim.g.gruvbox_contrast_light = contrast;
    vim.opt.background = "light";
  end,
  { nargs = "?", })

vim.opt.lazyredraw = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
-- some plugins misbehave when we do swap files
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath('state') .. '/.vim/undodir'
vim.opt.undofile = true
-- show menu even if there's 1 selection, and default to no selection
-- Note that we're not setitng `noinsert`, which allows us to "foresee" what the
-- completion would give us. This is faithful to VSCode
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }


-- vim.opt.clipboard = "unnamedplus"

-- more aggressive swap file writing. ThePrimeagen believes higher number leads to low DX
vim.opt.updatetime = 50

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- basic keymaps
-- Since we use space for leader, we're asserting that this does nothing by itself
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- make :terminal escape out. For zsh-vi-mode, just use Alt-Z or any keybind
-- that does not collide with vi-motion keybind. This is because
-- <Alt-x> -> ^[x; while <Esc> on the terminal is ^[
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>)')
vim.keymap.set({ 'n', 'i', 'v' }, '<c-l>', '<Cmd>mode<Cr>', { desc = "" }) -- redraw on every mode

-- diagnostics (errors/warnings to be shown)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float) -- opens diag in box (floating)
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist) -- opens list of diags
-- vim.keymap.set('n', '<leader>wq', vim.diagnostic.setqflist) -- workspace diags
vim.keymap.set('n', '<leader>q', '<cmd>TroubleToggle loclist<cr>')
vim.keymap.set('n', '<leader>wq', '<cmd>TroubleToggle workspace_diagnostics<cr>')
vim.keymap.set('n', '<leader>gg', '<cmd>GuessIndent<cr>')

-- color, highlighting, UI stuffs
vim.cmd([[
colorscheme gruvbox
]])
require('hlargs').setup()
require('nvim-web-devicons').setup()
require('trouble').setup {
  position = "bottom",            -- position of the list can be: bottom, top, left, right
  height = 10,                    -- height of the trouble list when position is top or bottom
  width = 50,                     -- width of the list when position is left or right
  icons = true,                   -- use devicons for filenames
  mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
  severity = nil,                 -- nil (ALL) or vim.diagnostic.severity.ERROR | WARN | INFO | HINT
  fold_open = "",              -- icon used for open folds
  fold_closed = "",            -- icon used for closed folds
  group = true,                   -- group results by file
  padding = true,                 -- add an extra new line on top of the list
  action_keys = {
    -- key mappings for actions in the trouble list
    -- map to {} to remove a mapping, for example:
    -- close = {},
    close = "q",                     -- close the list
    cancel = "<esc>",                -- cancel the preview and get back to your last window / buffer / cursor
    refresh = "r",                   -- manually refresh
    jump = { "<cr>", "<tab>" },      -- jump to the diagnostic or open / close folds
    open_split = { "<c-x>" },        -- open buffer in new split
    open_vsplit = { "<c-v>" },       -- open buffer in new vsplit
    open_tab = { "<c-t>" },          -- open buffer in new tab
    jump_close = { "o" },            -- jump to the diagnostic and close the list
    toggle_mode = "m",               -- toggle between "workspace" and "document" diagnostics mode
    switch_severity = "s",           -- switch "diagnostics" severity filter level to HINT / INFO / WARN / ERROR
    toggle_preview = "P",            -- toggle auto_preview
    hover = "K",                     -- opens a small popup with the full multiline message
    preview = "p",                   -- preview the diagnostic location
    close_folds = { "zM", "zm" },    -- close all folds
    open_folds = { "zR", "zr" },     -- open all folds
    toggle_fold = { "zA", "za" },    -- toggle fold of current file
    previous = "k",                  -- previous item
    next = "j"                       -- next item
  },
  indent_lines = true,               -- add an indent guide below the fold icons
  auto_open = false,                 -- automatically open the list when you have diagnostics
  auto_close = false,                -- automatically close the list when you have no diagnostics
  auto_preview = true,               -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
  auto_fold = false,                 -- automatically fold a file trouble list at creation
  auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
  signs = {
    -- icons / text used for a diagnostic
    error = "",
    warning = "",
    hint = "",
    information = "",
    other = "",
  },
  use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
}


-- TODO: Any way to collect all the TODOs and its variants?
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
local tel_actions = require("telescope.actions")
local tel_actionset = require("telescope.actions.set")

local function term_height()
  return vim.opt.lines:get()
end

require('telescope').setup {
  defaults = {
    mappings = {
      n = {
        ['<C-u>'] = function(prompt_bufnr) tel_actionset.shift_selection(prompt_bufnr, -math.floor(term_height() / 2)) end,
        ['<C-d>'] = function(prompt_bufnr) tel_actionset.shift_selection(prompt_bufnr, math.floor(term_height() / 2)) end,
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
      theme = require('telescope.themes').get_ivy().theme,
      hiject_netrw = true, -- disables netrw and use file-browser instead
      mappings = {
        ["i"] = {},        -- disable any shortcut in insert mode for now
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
  require("telescope").extensions.file_browser.file_browser({})
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
end, { desc = '[F]ind thru [G]rep' })

remap('n', '<leader>fug', function()
  -- This relies on many factors: We use `rg` and that `-g '**/*'` effectively
  -- drops ignore rules like the default `.gitignore` rule.
  require('telescope.builtin').live_grep({ glob_pattern = '**/*' })
end, { desc = '[F]ind thru [u]nrestricted [G]rep' })

remap('n', '<leader>fb', function()
  require('telescope.builtin').buffers()
end, { desc = '[F]ind existing [B]uffers' })

remap('n', '<leader>fh', function()
  require('telescope.builtin').help_tags()
end, { desc = '[F]ind [H]elp' })

remap('n', '<leader>fd', function()
  require('telescope.builtin').diagnostics()
end, { desc = '[F]ind [D]iagnostics' })

-- tab management {{{

-- Jump to specific tab with <C-t>[number]
for i = 1, 9 do
  vim.api.nvim_set_keymap('n', '<C-t>' .. i, ':tabn ' .. i .. '<CR>', { noremap = true, silent = true })
end

-- Show tab number in tab display
vim.o.showtabline = 1
vim.o.tabline = '%!v:lua.my_tabline()'

function _G.my_tabline()
  local s = ''
  for i = 1, vim.fn.tabpagenr('$') do
    if i == vim.fn.tabpagenr() then
      s = s .. '%' .. i .. 'T%#TabLineSel#'
    else
      s = s .. '%' .. i .. 'T%#TabLine#'
    end
    local tab = vim.fn.gettabinfo(i)[1]
    local tabbuf = tab.variables.buffers
    local bufname = "<unknown>"
    if tabbuf then
      bufname = tabbuf[tab.curwin].name
    end
    -- Canonicalize tab/buf name
    s = s .. ' ' .. i .. ' ' .. vim.fn.fnamemodify(bufname, ':t')
    if i ~= vim.fn.tabpagenr('$') then
      s = s .. '%#TabLine#|%#TabLine#'
    end
  end
  return s .. '%T%#TabLineFill#%='
end

-- Close all tabs except the first one
vim.api.nvim_set_keymap('n', '<C-t>x', ':tabdo if tabpagenr() > 1 | tabclose | endif<CR>',
  { noremap = true, silent = true, desc = "Close all tabs except the first one", })

-- }}}

-- treesitter
require 'treesitter-context'
require('nvim-treesitter.configs').setup {
  yati = {
    enable = true,
    default_lazy = true,
    default_fallback = "auto",
    disable = { "nix" }
  },
  indent = { enable = false },
  highlight = {
    enable = true,
    enable_vim_regex_highlighting = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<C-space>',
      node_incremental = '<C-space>',
      node_decremental = '<C-backspace>',
      scope_incremental = '<C-S>'
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
  playground = {
    enable = true,
    disable = {}
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
  auto_cmd = true,
  filetype_exclude = { -- A list of filetypes for which the auto command gets disabled
    "netrw",
    "tutor",
  },

  -- buftype_exclude = { -- A list of buffer types for which the auto command gets disabled
  --   "help",
  --   "nofile",
  --   "terminal",
  --   -- "prompt",
  -- },
}

-- harpoon: O(1) buffer/terminal switching
remap('n', '<leader>m', function() require('harpoon.mark').add_file() end, { desc = "[H]arpoon [M]ark" })
local function harpoon_nav(key, nav_file_index, lead_keybind)
  lead_keybind = lead_keybind or '<leader>h'
  assert(type(key) == "string", "expect key to be string(keybind)")
  assert(type(nav_file_index) == "number" and nav_file_index >= 1, "expect 1-indexed number for file index")
  return remap('n', lead_keybind .. key,
    function() require('harpoon.ui').nav_file(nav_file_index) end,
    { desc = "[H]arpoon navigate " .. tostring(nav_file_index) })
end

-- remap letters to index. Inspired by alternating number of Dvorak programmer
-- best practices: try to keep marked files to be around 4
harpoon_nav('f', 1)
harpoon_nav('j', 2)
harpoon_nav('d', 3)
harpoon_nav('k', 4)
remap('n', '<leader>hh', function() require('harpoon.ui').toggle_quick_menu() end)
for i = 1, 10 do
  -- harpoon: navigate files by numbers
  harpoon_nav(tostring(i % 10), i)
  -- harpoon: navigate terms by numbers
  remap('n', '<leader>t' .. tostring(i % 10), function()
    require('harpoon.term').gotoTerminal(i)
  end)
end

-- neogit: easy-to-see git status. Provides only productivity on staging/unstage
require('neogit').setup {}
remap('n', '<leader>gs', function() require('neogit').open({}) end, { desc = "[G]it [S]tatus" });

-- LSP settings
-- This function gets run when an LSP connects to a particular buffer.
require("inlay-hints").setup {
  -- renderer to use
  -- possible options are dynamic, eol, virtline and custom
  -- renderer = "inlay-hints/render/dynamic",
  renderer = "inlay-hints/render/eol",

  hints = {
    parameter = {
      show = true,
      highlight = "whitespace",
    },
    type = {
      show = true,
      highlight = "Whitespace",
    },
  },

  -- Only show inlay hints for the current line
  only_current_line = false,

  eol = {
    -- whether to align to the extreme right or not
    right_align = false,

    -- padding from the right if right_align is true
    right_align_padding = 7,

    parameter = {
      separator = ", ",
      format = function(hints)
        return string.format(" <- (%s)", hints)
      end,
    },

    type = {
      separator = ", ",
      format = function(hints)
        return string.format(" => %s", hints)
      end,
    },
  },
}


local on_attach = function(client, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { noremap = true, buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  -- NOTE: I have no clue what this does again
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  nmap('<leader>df', function() vim.lsp.buf.format({ async = true }) end, '[D]ocument [F]ormat')

  -- symbols and gotos
  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('gr', require('telescope.builtin').lsp_references)
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- documentations & helps
  -- NOTE: When you press K, it shows in-line Documentation
  -- This is to stay faithful with vim's default keybind for help.
  -- See `:help K` for even more info on Vim's original keybindings for help
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Less likely LSP functionality to be used
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('gtd', vim.lsp.buf.type_definition, '[G]oto [T]ype [D]efinition')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  --
  -- Very rarely used
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- enable inlay hints if available
  require('inlay-hints').on_attach(client, bufnr)
end

require("sg").setup {
  on_attach = on_attach,
}
-- nvim-cmp

local cmp = require 'cmp'
local luasnip = require 'luasnip'
local lspkind = require('lspkind')


lspkind.init {
  symbol_map = {
    Copilot = "",
  },
}
cmp.event:on(
  "confirm_done",
  require('nvim-autopairs.completion.cmp').on_confirm_done()
)


---@alias EntryFilter {id: integer, compe: lsp.CompletionItem, return_type: string, return_type2: string, score: number, label: string, source_name: string, bufnr: number?, offset: number?, kind: lsp.CompletionItemKind }
---@param entry cmp.Entry
---@return EntryFilter
local function entry_filter_sync(entry)
  local compe = entry:get_completion_item()
  local return_type = compe.data and compe.data.return_type
  local return_type2 = compe.detail
  local score = entry.score
  local label = compe.label
  local source_name = entry.source.name
  local bufnr = entry.context.bufnr
  local offset = entry:get_offset()
  local kind = entry:get_kind()
  local id = entry.id
  return {
    id = id,
    compe = compe,
    return_type = return_type,
    return_type2 = return_type2,
    score = score,
    label = label,
    source_name = source_name,
    bufnr = bufnr,
    offset = offset,
    kind = kind,
  }
end

---@param entry cmp.Entry
---@param callback fun(entry: EntryFilter): any
local function entry_filter(entry, callback)
  entry:resolve(function()
    callback(entry_filter_sync(entry))
  end)
end

---@type cmp.ConfigSchema
local cmp_config = {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-l'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.refresh()
      else
        fallback()
      end
      -- 'i': insert, 's': select, 'c': command
    end, { 'i', 's' }),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    -- NOTE: rebind tab and shift-tab since it may break whenever we
    -- need to peform manual indentation
    ['<C-j>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-k>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),

  },
  performance = {
    debounce = 60,
    throttle = 30,
  },
  formatting = {
    fields = { 'abbr', 'kind', 'menu' },
    -- vim_items: complete-items (`:h complete-items`)
    -- word, abbr, menu, info, kind, icase, equal, dup, empty, user_data
    format = function(entry, vim_item)
      local kind_fn = lspkind.cmp_format {
        with_text = true,
        menu = {
          buffer = "[buf]",
          nvim_lsp = "[LSP]",
          nvim_lua = "[api]",
          path = "[path]",
          luasnip = "[snip]",
          gh_issues = "[issues]",
          tn = "[TabNine]",
          eruby = "[erb]",
          nvim_lsp_signature_help = "[sig]",
        }
      }
      vim_item = kind_fn(entry, vim_item)

      -- copium that this will force resolve for entry
      entry_filter(entry, function(entry)
        if entry.source_name == "nvim_lsp" then
          log.debug('format:entry: ' .. vim.inspect(entry, { depth = 2 }))
        end
      end)

      return require('tailwindcss-colorizer-cmp').formatter(entry, vim_item)
    end,
  },
  sources = cmp.config.sources( --[[@as cmp.SourceConfig[]] {
    { name = 'nvim_lsp',               max_item_count = 30, },
    { name = 'nvim_lsp_signature_help' },
    -- NOTE: Path is triggered by `.` and `/`, so when it comes up, it's
    -- usually desirable.
    { name = 'path',                   max_item_count = 20, },
    { name = 'luasnip',                max_item_count = 20, },
    {
      name = 'buffer',
      option = {
        -- default is only in the current buffer. This grabs recommendations
        -- from all visible buffers
        get_bufnrs = function()
          -- Must always have current buffer
          local bufs = { [0] = true }
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
            if byte_size <= 1024 * 1024 then -- 1 MiB max
              bufs[buf] = true
            end
          end
          return vim.tbl_keys(bufs)
        end,
      },
      max_item_count = 20,
    }
    -- NOTE: I don't like cmdline that much. Most of the time, it recommends more harm than good
    -- { name = 'cmp_tabnine' },
    -- { name = "conjure" },
  }),
  experimental = { ghost_text = { hl_group = "Comment" }, },
  sorting = {
    comparators = {
      cmp.config.compare.exact,
      cmp.config.compare.recently_used,
      cmp.config.compare.offset,
      cmp.config.compare.score,
      cmp.config.compare.kind,
      cmp.config.compare.locality,
      cmp.config.compare.sort_text,
      cmp.config.compare.scope,
    },
  },
}


cmp.setup(vim.tbl_deep_extend("force", require('cmp.config.default')(), cmp_config))
-- set max autocomplete height. this prevents huge recommendations to take over the screen
vim.o.pumheight = 15 -- 15/70 is good enough ratio for me. I generally go with 80-90 max height, though
vim.o.pumblend = 10  -- semi-transparent for the art, nothing too useful (neovim recommends 0-30)

-- `/` cmdline search.
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})
-- `:` cmdline vim command.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    {
      name = 'cmdline',
      option = {
        ignore_cmds = { 'Man', '!' }
      }
    }
  })
})

-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- local tabnine = require('cmp_tabnine.config')
-- tabnine.setup({
-- max_lines = 1000,
-- max_num_results = 20,
-- sort = true,
-- run_on_every_keystroke = true,
-- snippet_placeholder = '..',
-- ignored_file_types = {},
-- show_prediction_strength = true,
-- })
-- default language servers
local servers = {
  'clangd', 'rust_analyzer', 'pyright', 'tsserver', 'lua_ls', 'cmake', 'tailwindcss', 'prismals',
  'nil_ls', 'eslint', 'terraformls', 'tflint', 'svelte', 'astro', 'clojure_lsp', "bashls", 'yamlls', "ansiblels",
  "jsonls", "denols", "gopls", "nickel_ls", 'pylsp',
}
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    },
    check_outdated_packages_on_open = true,
  },
  -- NOTE: The default settings is "prepend" https://github.com/williamboman/mason.nvim#default-configuration
  -- Which means Mason's installed path is prioritized against our local install
  -- see: https://git.pegasust.com/pegasust/aoc/commit/b45dc32c74d84c9f787ebce7a174c9aa1d411fc2
  -- This introduces some pitfalls, so we'll take the approach of trusting user's local installation
  PATH = "append",
})
require('mason-lspconfig').setup({
  -- ensure_installed = servers,
  ensure_installed = {
    "pylsp", "pyright", "tailwindcss", "svelte", "astro", "lua_ls", "tsserver",
    "ansiblels", "yamlls", "docker_compose_language_service", "jsonls",
  },
  automatic_installation = false,
})

local inlay_hint_tsjs = {
  includeInlayEnumMemberValueHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayParameterNameHints = 'all', -- "none" | "literals" | "all"
  inlcudeInlayParameterNameHintsWhenArgumentMatchesName = false,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayVariableTypeHints = true,
};

local setup = {
  ["nil_ls"] = function()
    require('lspconfig').nil_ls.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      --- refer to https://github.com/oxalica/nil/blob/main/docs/configuration.md
      --- for the list of configurations available for `nil_ls`
      settings = {
        ["nil"] = {
          formatting = {
            command = { "nix", "run", "nixpkgs#alejandra" },
          },
          nix = {
            flake = {
              -- calls `nix flake archive` to put a flake and its output to store
              autoArchive = true,
              -- auto eval flake inputs for improved completion
              autoEvalInputs = true,
            },
          },
        },
      },
    }
  end,
  ["gopls"] = function()
    local util = require 'lspconfig.util'
    local mod_cache = nil

    require('lspconfig').gopls.setup {
      {
        -- NOTE: might just change to `nix run nixpkgs#gopls` for simplicity here
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        root_dir = function(fname)
          -- see: https://github.com/neovim/nvim-lspconfig/issues/804
          if not mod_cache then
            local result = util.async_run_command 'go env GOMODCACHE'
            if result and result[1] then
              mod_cache = vim.trim(result[1])
            end
          end
          if fname:sub(1, #mod_cache) == mod_cache then
            local clients = vim.lsp.get_active_clients { name = 'gopls' }
            if #clients > 0 then
              return clients[#clients].config.root_dir
            end
          end
          return util.root_pattern('go.work', 'go.mod', '.git')(fname)
        end,
        single_file_support = true,
      },
      docs = {
        description = [[
https://github.com/golang/tools/tree/master/gopls

Google's lsp server for golang.
]],
        default_config = {
          root_dir = [[root_pattern("go.work", "go.mod", ".git")]],
        },
      }
    }
  end
}

require('mason-lspconfig').setup_handlers({
  -- default handler
  function(server_name)
    require('lspconfig')[server_name].setup {
      on_attach = on_attach,
      capabilities = capabilities,
    }
  end,
  ["lua_ls"] = function()
    require('lspconfig').lua_ls.setup {
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
            library = vim.api.nvim_get_runtime_file('', true),
            -- Don't prompt me to select
            checkThirdParty = false,
          },
          telemetry = { enable = false },
          hint = {
            enable = true,
          },
          format = {
            enable = true,
            defaultConfig = {
              indent_style = "space",
              indent_size = 4,
            },
          },
        },
      },
    }
  end,
  ["pyright"] = function()
    require('lspconfig').pyright.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        pyright = {
          disableLanguageServices = false,
          disableOrganizeImports = false,
        },
        python = {
          analysis = {
            autoImportCompletions = true,
            autoSearchPaths = true,
            diagnosticMode = "openFilesOnly",
            -- diagnosticSeverityOverrides =
            extraPaths = {},
            logLevel = "Information",
            stubPath = "typings",
            typeCheckingMode = "basic",
            typeshedPaths = {},
            useLibraryCodeForTypes = false,
            pythonPath = "python",
            venvPath = "",
          },
          linting = {
            mypyEnabled = true,
          }
        },
      },
    }
  end,
  ["tsserver"] = function()
    require('lspconfig').tsserver.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      -- TODO: Have to figure out an alternative config for monorepo to prevent
      -- Deno from injecting TS projects.
      -- Monorepo support: spawn one instance of lsp within the git
      -- repos.
      -- root_dir = require('lspconfig.util').root_pattern('.git'),
      root_dir = require('lspconfig.util').root_pattern('package.json'),
      settings = {
        javascript = inlay_hint_tsjs,
        typescript = inlay_hint_tsjs,
      }
    }
  end,
  ["denols"] = function()
    require('lspconfig').denols.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      root_dir = require('lspconfig.util').root_pattern("deno.json", "deno.jsonc"),
    }
  end,
  ["yamlls"] = function()
    require('lspconfig').yamlls.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        yaml = {
          keyOrdering = false,
        }
      },
    }
  end,
})

setup["nil_ls"]()
setup["gopls"]()
require("rust-tools").setup {
  tools = {
    -- rust-tools options

    -- how to execute terminal commands
    -- options right now: termopen / quickfix
    executor = require("rust-tools/executors").termopen,
    -- callback to execute once rust-analyzer is done initializing the workspace
    -- The callback receives one parameter indicating the `health` of the server: "ok" | "warning" | "error"
    on_initialized = function()
      require('inlay-hints').set_all()
    end,
    -- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
    reload_workspace_from_cargo_toml = true,
    -- These apply to the default RustSetInlayHints command
    inlay_hints = {
      -- automatically set inlay hints (type hints)
      -- default: true
      auto = false,
      -- Only show inlay hints for the current line
      only_current_line = true,
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
      -- The color of the hints use `:highlight` for a pick-and-choose menu
      highlight = "NonText",
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
      on_attach(client, bufnr)
      nmap('K', require 'rust-tools'.hover_actions.hover_actions, 'Hover Documentation')
    end,
    capabilities = capabilities,
    cmd = { "rust-analyzer" },
    settings = {
      ["rust-analyzer"] = {
        -- enable clippy on save
        checkOnSave = {
          command = "clippy",
          extraArgs = { "--all", "--", "-W", "clippy::all" },
        },
        rustfmt = {
          extraArgs = { "+nightly" },
        },
        cargo = {
          loadOutDirsFromCheck = true,
        },
        procMacro = {
          enable = true,
        },
      },
    },
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
      {
        'filename',
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
require('fidget').setup({
  text = {
    spinner = "moon",        -- animation shown when tasks are ongoing
    done = "✔",            -- character shown when all tasks are complete
    commenced = "Started",   -- message shown when task starts
    completed = "Completed", -- message shown when task completes
  },
  align = {
    bottom = true, -- align fidgets along bottom edge of buffer
    right = true,  -- align fidgets along right edge of buffer
  },
  timer = {
    spinner_rate = 125,  -- frame rate of spinner animation, in ms
    fidget_decay = 2000, -- how long to keep around empty fidget, in ms
    task_decay = 1000,   -- how long to keep around completed task, in ms
  },
  window = {
    relative = "editor", -- where to anchor, either "win" or "editor"
    blend = 100,         -- &winblend for the window
    zindex = nil,        -- the zindex value for the window
    border = "none",     -- style of border for the fidget window
  },
  fmt = {
    leftpad = true,       -- right-justify text in fidget box
    stack_upwards = true, -- list of tasks grows upwards
    max_width = 0,        -- maximum width of the fidget box
    fidget =              -- function to format fidget title
        function(fidget_name, spinner)
          return string.format("%s %s", spinner, fidget_name)
        end,
    task = -- function to format each task line
        function(task_name, message, percentage)
          return string.format(
            "%s%s [%s]",
            message,
            percentage and string.format(" (%s%%)", percentage) or "",
            task_name
          )
        end,
  },
  sources = {
    -- Sources to configure
    ['*'] = {         -- Name of source
      ignore = false, -- Ignore notifications from this source
    },
  },
  debug = {
    logging = false, -- whether to enable logging, for debugging
    strict = false,  -- whether to interpret LSP strictly
  },
})

-- Messaages as buf because it's so limiting to work with builtin view menu from neovim
vim.api.nvim_create_user_command('ShowLogs', function(opts)
  local plugin_name = opts.fargs[1] or PLUGIN_URI
  local min_level = opts.fargs[2] or PLUGIN_LEVEL
  local logfile = string.format("%s/%s.log", vim.api.nvim_call_function("stdpath", { "cache" }), plugin_name)

  -- Ensure that the logfile exists
  local file = io.open(logfile, 'r')
  if not file then
    print(string.format("No logfile found for plugin '%s'", vim.inspect(plugin_name)))
    print("Attempted paths: %s", vim.inspect(logfile))
    return
  end
  file:close()

  vim.cmd('vnew ' .. logfile)

  -- Load messages from the log file
  local file_messages = vim.fn.readfile(logfile)
  local levels = { trace = 1, debug = 2, info = 3, warn = 4, error = 5, fatal = 6 }
  local min_index = levels[min_level] or 3
  local filtered_messages = {}
  for _, message in ipairs(file_messages) do
    local level = message:match("^%[([a-z]+)")
    if levels[level] and levels[level] >= min_index then
      table.insert(filtered_messages, message)
    end
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, filtered_messages)
  vim.cmd('setlocal ft=log')
  vim.cmd('setlocal nomodifiable')
end, { nargs = "*", })

require("colorizer").setup {
  filetypes = { "*" },
  user_default_options = {
    RGB = true,          -- #RGB hex codes
    RRGGBB = true,       -- #RRGGBB hex codes
    names = true,        -- "Name" codes like Blue or blue
    RRGGBBAA = true,     -- #RRGGBBAA hex codes
    AARRGGBB = true,     -- 0xAARRGGBB hex codes
    rgb_fn = true,       -- CSS rgb() and rgba() functions
    hsl_fn = true,       -- CSS hsl() and hsla() functions
    css = true,          -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
    css_fn = true,       -- Enable all CSS *functions*: rgb_fn, hsl_fn
    -- Available modes for `mode`: foreground, background, virtualtext
    mode = "background", -- Set the display mode.
    -- Available methods are false / true / "normal" / "lsp" / "both"
    -- True is same as normal
    tailwind = true,                                -- Enable tailwind colors
    -- parsers can contain values used in |user_default_options|
    sass = { enable = true, parsers = { "css" }, }, -- Enable sass colors
    virtualtext = "■",
    -- update color values even if buffer is not focused
    -- example use: cmp_menu, cmp_docs
    always_update = false
  },
  -- all the sub-options of filetypes apply to buftypes
  buftypes = {},
}
