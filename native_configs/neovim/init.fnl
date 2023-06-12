(vim.cmd "let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
let plug_path = data_dir . '/autoload/plug.vim'
if empty(glob(plug_path))
    execute '!curl -fLo '.plug_path.' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    execute 'so '.plug_path
endif
")
(local Plug (. vim.fn "plug#"))
(local installed-plugins {})
(each [_ path (ipairs (vim.api.nvim_list_runtime_paths))]
  (local last-folder-start (path:find "/[^/]*$"))
  (when last-folder-start
    (local plugin-name (path:sub (+ last-folder-start 1)))
    (tset installed-plugins plugin-name true)))
(fn WPlug [plugin-path ...]
  (let [plugin-name (string.lower (plugin-path:match "/([^/]+)$"))]
    (when (not (. installed-plugins plugin-name)) (Plug plugin-path ...))))
(vim.call "plug#begin")
(WPlug :tjdevries/nlua.nvim)
(WPlug :nvim-treesitter/nvim-treesitter)
(WPlug :nvim-treesitter/nvim-treesitter-textobjects)
(WPlug :nvim-telescope/telescope.nvim {:branch :0.1.x})
(WPlug :nvim-telescope/telescope-fzf-native.nvim {:do "make >> /tmp/log 2>&1"})
(WPlug :nvim-telescope/telescope-file-browser.nvim)
(WPlug :neovim/nvim-lspconfig)
(WPlug :hrsh7th/cmp-nvim-lsp)
(WPlug :hrsh7th/cmp-path)
(WPlug :hrsh7th/cmp-buffer)
(WPlug :hrsh7th/cmp-cmdline)
(WPlug :hrsh7th/nvim-cmp)
(WPlug :onsails/lspkind-nvim)
(WPlug :yioneko/nvim-yati {:tag "*"})
(WPlug :nathanalderson/yang.vim)
(WPlug :windwp/nvim-autopairs)
(WPlug :windwp/nvim-ts-autotag)
(WPlug :NMAC427/guess-indent.nvim)
(WPlug :j-hui/fidget.nvim)
(WPlug :numToStr/Comment.nvim)
(WPlug :lewis6991/gitsigns.nvim)
(WPlug :tpope/vim-fugitive)
(WPlug :williamboman/mason.nvim)
(WPlug :williamboman/mason-lspconfig.nvim)
(WPlug :ThePrimeagen/harpoon)
(WPlug :TimUntersberger/neogit)
(WPlug :folke/trouble.nvim)
(WPlug :tpope/vim-dispatch)
(WPlug :clojure-vim/vim-jack-in)
(WPlug :radenling/vim-dispatch-neovim)
(WPlug :gennaro-tedesco/nvim-jqx)
(WPlug :kylechui/nvim-surround)
(WPlug :simrat39/rust-tools.nvim)
(WPlug :simrat39/inlay-hints.nvim)
(WPlug :gruvbox-community/gruvbox)
(WPlug :nvim-lualine/lualine.nvim)
(WPlug :lukas-reineke/indent-blankline.nvim)
(WPlug :kyazdani42/nvim-web-devicons)
(WPlug :m-demare/hlargs.nvim)
(WPlug :folke/todo-comments.nvim)
(WPlug :nvim-treesitter/nvim-treesitter-context)
(WPlug :nvim-treesitter/playground)
(WPlug :saadparwaiz1/cmp_luasnip)
(WPlug :L3MON4D3/LuaSnip)
(WPlug :mickael-menu/zk-nvim)
(WPlug :arthurxavierx/vim-caser)
(WPlug "~/local_repos/ts-ql")
(vim.call "plug#end")
(vim.cmd "if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    PlugInstall --sync | autocmd VimEnter * so $MYVIMRC
endif
")
(vim.api.nvim_create_autocmd [:VimEnter]
                             {:callback (fn []
                                          (fn named-term [term-idx term-name]
                                            ((. (require :harpoon.term)
                                                :gotoTerminal) term-idx)
                                            (vim.cmd (.. ":exe \":file "
                                                         term-name
                                                         "\" | :bfirst")))

                                          (named-term 4 "term:ctl")
                                          (named-term 5 "term:dev")
                                          (named-term 7 "term:repl")
                                          (named-term 6 "term:repl2"))})
(set vim.g.gruvbox_contrast_dark :soft)
(set vim.g.gruvbox_contrast_light :soft)
(set vim.opt.ignorecase true)
(set vim.opt.smartcase true)
(set vim.opt.incsearch true)
(set vim.opt.number true)
(set vim.opt.relativenumber true)
(set vim.opt.autoindent true)
(set vim.opt.smartindent true)
(set vim.opt.expandtab true)
(set vim.opt.exrc true)
(set vim.opt.tabstop 4)
(set vim.opt.softtabstop 4)
(set vim.opt.shiftwidth 4)
(set vim.opt.scrolloff 30)
(set vim.opt.signcolumn :yes)
(set vim.opt.colorcolumn :80)
(set vim.opt.background :dark)
(vim.api.nvim_create_user_command :Dark
                                  (fn [opts]
                                    (let [contrast (or (and (and opts.args
                                                                 (> (string.len opts.args)
                                                                    0))
                                                            opts.args)
                                                       vim.g.gruvbox_contrast_dark)]
                                      (set vim.g.gruvbox_contrast_dark contrast)
                                      (set vim.opt.background :dark)))
                                  {:nargs "?"})
(vim.api.nvim_create_user_command :Light
                                  (fn [opts]
                                    (let [contrast (or (and (and opts.args
                                                                 (> (string.len opts.args)
                                                                    0))
                                                            opts.args)
                                                       vim.g.gruvbox_contrast_light)]
                                      (set vim.g.gruvbox_contrast_light
                                           contrast)
                                      (set vim.opt.background :light)))
                                  {:nargs "?"})
(set vim.opt.lazyredraw true)
(set vim.opt.termguicolors true)
(set vim.opt.cursorline true)
(set vim.opt.swapfile false)
(set vim.opt.backup false)
(set vim.opt.undodir (.. (vim.fn.stdpath :state) :/.vim/undodir))
(set vim.opt.undofile true)
(set vim.opt.completeopt "menuone,noselect")
(set vim.opt.updatetime 50)
(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")
(vim.keymap.set [:n :v] :<Space> :<Nop> {:silent true})
(vim.keymap.set :t :<Esc> "<C-\\><C-n>)")
(vim.keymap.set [:n :i :v] :<c-l> :<Cmd>mode<Cr> {:desc ""})
(vim.keymap.set :n "[d" vim.diagnostic.goto_prev)
(vim.keymap.set :n "]d" vim.diagnostic.goto_next)
(vim.keymap.set :n :<leader>e vim.diagnostic.open_float)
(vim.keymap.set :n :<leader>q "<cmd>TroubleToggle loclist<cr>")
(vim.keymap.set :n :<leader>wq "<cmd>TroubleToggle workspace_diagnostics<cr>")
(vim.keymap.set :n :<leader>gg :<cmd>GuessIndent<cr>)
(vim.cmd "colorscheme gruvbox\n")
((. (require :hlargs) :setup))
((. (require :nvim-web-devicons) :setup))
((. (require :trouble) :setup))
((. (require :todo-comments) :setup))
(fn remap [mode key-cmd binded-fn opts]
  (set-forcibly! opts (or opts {:remap true}))
  (vim.keymap.set mode key-cmd binded-fn opts))
((. (require :Comment) :setup))
(set vim.opt.list true)
(vim.opt.listchars:append "space:⋅")
(vim.opt.listchars:append "eol:↴")
((. (require :indent_blankline) :setup) {:show_end_of_line true
                                         :space_char_blankline " "})
(vim.api.nvim_create_user_command :HalfSpaces
                                  (fn [opts]
                                    (vim.api.nvim_command "set ts=2 sts=2 noet")
                                    (vim.api.nvim_command :retab!)
                                    (vim.api.nvim_command "set ts=1 sts=1 et")
                                    (vim.api.nvim_command :retab)
                                    (vim.api.nvim_command :GuessIndent))
                                  {:nargs 0})
(vim.api.nvim_create_user_command :DoubleSpaces
                                  (fn [opts]
                                    (vim.api.nvim_command "set ts=2 sts=2 noet")
                                    (vim.api.nvim_command :retab!)
                                    (vim.api.nvim_command "set ts=4 sts=4 et")
                                    (vim.api.nvim_command :retab)
                                    (vim.api.nvim_command :GuessIndent))
                                  {:nargs 0})
(local fb-actions (. (. (. (require :telescope) :extensions) :file_browser)
                     :actions))
((. (require :telescope) :setup) {:defaults {:mappings {:i {:<C-d> false
                                                            :<C-u> false}}}
                                  :extensions {:file_browser {:hiject_netrw true
                                                              :mappings {:i {}
                                                                         :n {:c fb-actions.create
                                                                             :d fb-actions.remove
                                                                             :e fb-actions.goto_home_dir
                                                                             :f fb-actions.toggle_browser
                                                                             :g fb-actions.goto_parent_dir
                                                                             :h fb-actions.toggle_hidden
                                                                             :m fb-actions.move
                                                                             :o fb-actions.open
                                                                             :r fb-actions.rename
                                                                             :s fb-actions.toggle_all
                                                                             :t fb-actions.change_cwd
                                                                             :w fb-actions.goto_cwd
                                                                             :y fb-actions.copy}}
                                                              :theme (. ((. (require :telescope.themes)
                                                                            :get_ivy))
                                                                        :theme)}
                                               :fzf {:case_mode :smart_case
                                                     :fuzzy true
                                                     :override_file_sorter true
                                                     :override_generic_sorter true}}})
(pcall (. (require :telescope) :load_extension) :fzf)
(pcall (. (require :telescope) :load_extension) :file_browser)
(remap :n :<C-p> :<cmd>Telescope<cr> {:desc "Open Telescope general search"})
(remap :n :<leader>fm (fn []
                        ((. (. (. (require :telescope) :extensions)
                               :file_browser)
                            :file_browser) {}))
       {:desc "[F]ile [M]utation"})
(remap :n :<leader>ff
       (fn []
         ((. (require :telescope.builtin) :find_files) {:follow false
                                                        :hidden false
                                                        :no_ignore false}))
       {:desc "[F]ind [F]ile"})
(remap :n :<leader>fa
       (fn []
         ((. (require :telescope.builtin) :find_files) {:follow true
                                                        :hidden true
                                                        :no_ignore true}))
       {:desc "[F]ind [A]ll files"})
(remap :n :<leader>fg
       (fn []
         ((. (require :telescope.builtin) :live_grep)))
       {:desc "[F]ind by [G]rep"})
(remap :n :<leader>fug
       (fn []
         ((. (require :telescope.builtin) :live_grep) {:glob_pattern "**/*"}))
       {:desc "[F]ind by [u]nrestricted [G]rep"})
(remap :n :<leader>fb
       (fn []
         ((. (require :telescope.builtin) :buffers)))
       {:desc "[F]ind existing [B]uffers"})
(remap :n :<leader>fh
       (fn []
         ((. (require :telescope.builtin) :help_tags)))
       {:desc "[F]ind [H]elp"})
(remap :n :<leader>fd
       (fn []
         ((. (require :telescope.builtin) :diagnostics)))
       {:desc "[F]ind [D]iagnostics"})
(remap :n :<leader>zf
       (fn []
         ((. (require :zk) :edit) {} {:multi_select false}))
       {:desc "[Z]ettelkasten [F]iles"})
(remap :n :<leader>zg (fn [] (vim.cmd ":ZkGrep"))
       {:desc "[Z]ettelkasten [G]rep"})
(for [i 1 9]
  (vim.api.nvim_set_keymap :n (.. :<C-t> i) (.. ":tabn " i :<CR>)
                           {:noremap true :silent true}))
(set vim.o.showtabline 1)
(set vim.o.tabline "%!v:lua.my_tabline()")
(fn _G.my_tabline []
  (var s "")
  (for [i 1 (vim.fn.tabpagenr "$")]
    (if (= i (vim.fn.tabpagenr)) (set s (.. s "%" i "T%#TabLineSel#"))
        (set s (.. s "%" i "T%#TabLine#")))
    (local tab (. (vim.fn.gettabinfo i) 1))
    (local tabbuf tab.variables.buffers)
    (var bufname :<unknown>)
    (when tabbuf
      (set bufname (. (. tabbuf tab.curwin) :name)))
    (set s (.. s " " i " " (vim.fn.fnamemodify bufname ":t")))
    (when (not= i (vim.fn.tabpagenr "$"))
      (set s (.. s "%#TabLine#|%#TabLine#"))))
  (.. s "%T%#TabLineFill#%="))
(vim.api.nvim_set_keymap :n :<C-t>x
                         ":tabdo if tabpagenr() > 1 | tabclose | endif<CR>"
                         {:noremap true :silent true})
(require :treesitter-context)
((. (require :nvim-treesitter.configs) :setup) {:autotag {:enable true}
                                                :highlight {:enable true
                                                            :enable_vim_regex_highlighting true}
                                                :incremental_selection {:enable true
                                                                        :keymaps {:init_selection :<C-space>
                                                                                  :node_decremental :<C-backspace>
                                                                                  :node_incremental :<C-space>
                                                                                  :pscope_incremental :<C-S>}}
                                                :indent {:enable false}
                                                :playground {:disable {}
                                                             :enable true}
                                                :textobjects {:select {:enable true
                                                                       :keymaps {:ac "@class.outer"
                                                                                 :af "@function.outer"
                                                                                 :ic "@class.inner"
                                                                                 :if "@function.inner"}
                                                                       :lookahead true}}
                                                :yati {:default_fallback :auto
                                                       :default_lazy true
                                                       :disable [:nix]
                                                       :enable true}})
((. (require :nvim-autopairs) :setup) {:check_ts true})
(local parser-config
       ((. (require :nvim-treesitter.parsers) :get_parser_configs)))
(set parser-config.tsx.filetype_to_parsername [:javascript :typescript.tsx])
(set parser-config.astro.filetype_to_parsername
     [:javascript :typescript.tsx :astro])
((. (require :guess-indent) :setup) {:auto_cmd true
                                     :filetype_exclude [:netrw :tutor]})
(remap :n :<leader>m
       (fn []
         ((. (require :harpoon.mark) :add_file)))
       {:desc "[H]arpoon [M]ark"})
(fn harpoon-nav [key nav-file-index lead-keybind]
  (set-forcibly! lead-keybind (or lead-keybind :<leader>h))
  (assert (= (type key) :string) "expect key to be string(keybind)")
  (assert (and (= (type nav-file-index) :number) (>= nav-file-index 1))
          "expect 1-indexed number for file index")
  (remap :n (.. lead-keybind key)
         (fn []
           ((. (require :harpoon.ui) :nav_file) nav-file-index))
         {:desc (.. "[H]arpoon navigate " (tostring nav-file-index))}))
(harpoon-nav :f 1)
(harpoon-nav :j 2)
(harpoon-nav :d 3)
(harpoon-nav :k 4)
(remap :n :<leader>hh
       (fn []
         ((. (require :harpoon.ui) :toggle_quick_menu))))
(for [i 1 10]
  (harpoon-nav (tostring (% i 10)) i)
  (remap :n (.. :<leader>t (tostring (% i 10)))
         (fn []
           ((. (require :harpoon.term) :gotoTerminal) i))))
((. (require :neogit) :setup) {})
(remap :n :<leader>gs (fn []
                        ((. (require :neogit) :open) {}))
       {:desc "[G]it [S]tatus"})
((. (require :inlay-hints) :setup) {:eol {:right_align false}
                                    :only_current_line false})
(fn on-attach [client bufnr]
  (fn nmap [keys func desc]
    (when desc (set-forcibly! desc (.. "LSP: " desc)))
    (vim.keymap.set :n keys func {:buffer bufnr : desc :noremap true}))

  (nmap :<leader>rn vim.lsp.buf.rename "[R]e[n]ame")
  (nmap :<leader>ca vim.lsp.buf.code_action "[C]ode [A]ction")
  (vim.api.nvim_buf_set_option bufnr :omnifunc "v:lua.vim.lsp.omnifunc")
  (nmap :<leader>df (fn [] (vim.lsp.buf.format {:async true}))
        "[D]ocument [F]ormat")
  (nmap :gd vim.lsp.buf.definition "[G]oto [D]efinition")
  (nmap :gi vim.lsp.buf.implementation "[G]oto [I]mplementation")
  (nmap :gr (. (require :telescope.builtin) :lsp_references))
  (nmap :<leader>ds (. (require :telescope.builtin) :lsp_document_symbols)
        "[D]ocument [S]ymbols")
  (nmap :<leader>ws (. (require :telescope.builtin)
                       :lsp_dynamic_workspace_symbols)
        "[W]orkspace [S]ymbols")
  (nmap :K vim.lsp.buf.hover "Hover Documentation")
  (nmap :<C-k> vim.lsp.buf.signature_help "Signature Documentation")
  (nmap :gD vim.lsp.buf.declaration "[G]oto [D]eclaration")
  (nmap :gtd vim.lsp.buf.type_definition "[G]oto [T]ype [D]efinition")
  (nmap :<leader>D vim.lsp.buf.type_definition "Type [D]efinition")
  (nmap :<leader>wa vim.lsp.buf.add_workspace_folder "[W]orkspace [A]dd Folder")
  (nmap :<leader>wr vim.lsp.buf.remove_workspace_folder
        "[W]orkspace [R]emove Folder")
  (nmap :<leader>wl
        (fn []
          (print (vim.inspect (vim.lsp.buf.list_workspace_folders))))
        "[W]orkspace [L]ist Folders")
  ((. (require :inlay-hints) :on_attach) client bufnr))
(local cmp (require :cmp))
(local luasnip (require :luasnip))
(local lspkind (require :lspkind))
(local source-mapping {:buffer "[Buffer]"
                       :nvim_lsp "[LSP]"
                       :nvim_lua "[Lua]"
                       :path "[Path]"})
(cmp.event:on :confirm_done ((. (require :nvim-autopairs.completion.cmp)
                                :on_confirm_done)))
(cmp.setup {:formatting {:format (fn [entry vim-item]
                                   (set vim-item.kind
                                        (lspkind.symbolic vim-item.kind
                                                          {:mode :symbol}))
                                   (set vim-item.menu
                                        (. source-mapping entry.source_name))
                                   (local maxwidth 80)
                                   (set vim-item.abbr
                                        (string.sub vim-item.abbr 1 maxwidth))
                                   vim-item)}
            :mapping (cmp.mapping.preset.insert {:<C-d> (cmp.mapping.scroll_docs 4)
                                                 :<C-space> (cmp.mapping.complete)
                                                 :<C-u> (cmp.mapping.scroll_docs (- 4))
                                                 :<CR> (cmp.mapping.confirm {:behavior cmp.ConfirmBehavior.Replace
                                                                             :select true})
                                                 :<S-Tab> (cmp.mapping (fn [fallback]
                                                                         (if (cmp.visible)
                                                                             (cmp.select_prev_item)
                                                                             (luasnip.jumpable (- 1))
                                                                             (luasnip.jump (- 1))
                                                                             (fallback)))
                                                                       [:i :s])
                                                 :<Tab> (cmp.mapping (fn [fallback]
                                                                       (if (cmp.visible)
                                                                           (cmp.select_next_item)
                                                                           (luasnip.expand_or_jumpable)
                                                                           (luasnip.expand_or_jump)
                                                                           (fallback)))
                                                                     [:i :s])})
            :snippet {:expand (fn [args] (luasnip.lsp_expand args.body))}
            :sources (cmp.config.sources [{:name :nvim_lsp}
                                          {:name :luasnip}
                                          {:name :buffer}
                                          {:name :path}])})
(local capabilities ((. (require :cmp_nvim_lsp) :default_capabilities)))
(local servers [:clangd
                :rust_analyzer
                :pyright
                :tsserver
                :lua_ls
                :cmake
                :tailwindcss
                :prismals
                :rnix
                :eslint
                :terraformls
                :tflint
                :svelte
                :astro
                :clojure_lsp
                :bashls
                :yamlls
                :ansiblels
                :jsonls
                :denols
                :gopls
                :nickel_ls
                :pylsp])
((. (require :mason) :setup) {:PATH :append
                              :ui {:check_outdated_packages_on_open true
                                   :icons {:package_installed "✓"
                                           :package_pending "➜"
                                           :package_uninstalled "✗"}}})
((. (require :mason-lspconfig) :setup) {:automatic_installation false})
(local inlay-hint-tsjs
       {:includeInlayEnumMemberValueHints true
        :includeInlayFunctionLikeReturnTypeHints true
        :includeInlayFunctionParameterTypeHints true
        :includeInlayParameterNameHints :all
        :includeInlayPropertyDeclarationTypeHints true
        :includeInlayVariableTypeHints true
        :inlcudeInlayParameterNameHintsWhenArgumentMatchesName false})
((. (require :mason-lspconfig) :setup_handlers) {1 (fn [server-name]
                                                     ((. (. (require :lspconfig)
                                                            server-name)
                                                         :setup) {: capabilities
                                                                                                                                                                                                                            :on_attach on-attach}))
                                                 :denols (fn []
                                                           ((. (. (require :lspconfig)
                                                                  :denols)
                                                               :setup) {: capabilities
                                                                                                                                                                                                                                          :on_attach on-attach
                                                                                                                                                                                                                                          :root_dir ((. (require :lspconfig.util)
                                                                                                                                                                                                                                                        :root_pattern) :deno.json
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         :deno.jsonc)}))
                                                 :lua_ls (fn []
                                                           ((. (. (require :lspconfig)
                                                                  :lua_ls)
                                                               :setup) {: capabilities
                                                                                                                                                                                                                                          :on_attach on-attach
                                                                                                                                                                                                                                          :settings {:Lua {:diagnostics {:globals [:vim]}
                                                                                                                                                                                                                                                           :format {:defaultConfig {:indent_size 4
                                                                                                                                                                                                                                                                                    :indent_style :space}
                                                                                                                                                                                                                                                                    :enable true}
                                                                                                                                                                                                                                                           :hint {:enable true}
                                                                                                                                                                                                                                                           :runtime {:path (vim.split package.path
                                                                                                                                                                                                                                                                                      ";")
                                                                                                                                                                                                                                                                     :version :LuaJIT}
                                                                                                                                                                                                                                                           :telemetry {:enable false}
                                                                                                                                                                                                                                                           :workspace {:library (vim.api.nvim_get_runtime_file ""
                                                                                                                                                                                                                                                                                                               true)}}}}))
                                                 :pyright (fn []
                                                            ((. (. (require :lspconfig)
                                                                   :pyright)
                                                                :setup) {: capabilities
                                                                                                                                                                                                                                              :on_attach on-attach
                                                                                                                                                                                                                                              :settings {:pyright {:disableLanguageServices false
                                                                                                                                                                                                                                                                   :disableOrganizeImports false}
                                                                                                                                                                                                                                                         :python {:analysis {:autoImportCompletions true
                                                                                                                                                                                                                                                                             :autoSearchPaths true
                                                                                                                                                                                                                                                                             :diagnosticMode :openFilesOnly
                                                                                                                                                                                                                                                                             :extraPaths {}
                                                                                                                                                                                                                                                                             :logLevel :Information
                                                                                                                                                                                                                                                                             :pythonPath :python
                                                                                                                                                                                                                                                                             :stubPath :typings
                                                                                                                                                                                                                                                                             :typeCheckingMode :basic
                                                                                                                                                                                                                                                                             :typeshedPaths {}
                                                                                                                                                                                                                                                                             :useLibraryCodeForTypes false
                                                                                                                                                                                                                                                                             :venvPath ""}
                                                                                                                                                                                                                                                                  :linting {:mypyEnabled true}}}}))
                                                 :tsserver (fn []
                                                             ((. (. (require :lspconfig)
                                                                    :tsserver)
                                                                 :setup) {: capabilities
                                                                                                                                                                                                                                                  :on_attach on-attach
                                                                                                                                                                                                                                                  :root_dir ((. (require :lspconfig.util)
                                                                                                                                                                                                                                                                :root_pattern) :package.json)
                                                                                                                                                                                                                                                  :settings {:javascript inlay-hint-tsjs
                                                                                                                                                                                                                                                             :typescript inlay-hint-tsjs}}))
                                                 :yamlls (fn []
                                                           ((. (. (require :lspconfig)
                                                                  :yamlls)
                                                               :setup) {: capabilities
                                                                                                                                                                                                                                          :on_attach on-attach
                                                                                                                                                                                                                                          :settings {:yaml {:keyOrdering false}}}))})
((. (require :rust-tools) :setup) {:dap {:adapter {:command :lldb-vscode
                                                   :name :rt_lldb
                                                   :type :executable}}
                                   :server {: capabilities
                                            :cmd [:rust-analyzer]
                                            :on_attach (fn [client bufnr]
                                                         (fn nmap [keys
                                                                   func
                                                                   desc]
                                                           (when desc
                                                             (set-forcibly! desc
                                                                            (.. "LSP: "
                                                                                desc)))
                                                           (vim.keymap.set :n
                                                                           keys
                                                                           func
                                                                           {:buffer bufnr
                                                                            : desc
                                                                            :noremap true}))

                                                         (on-attach client
                                                                    bufnr)
                                                         (nmap :K
                                                               (. (. (require :rust-tools)
                                                                     :hover_actions)
                                                                  :hover_actions)
                                                               "Hover Documentation"))
                                            :settings {:rust-analyzer {:cargo {:loadOutDirsFromCheck true}
                                                                       :checkOnSave {:command :clippy
                                                                                     :extraArgs [:--all
                                                                                                 "--"
                                                                                                 :-W
                                                                                                 "clippy::all"]}
                                                                       :procMacro {:enable true}
                                                                       :rustfmt {:extraArgs [:+nightly]}}}
                                            :standalone true}
                                   :tools {:crate_graph {:backend :x11
                                                         :enabled_graphviz_backends [:bmp
                                                                                     :cgimage
                                                                                     :canon
                                                                                     :dot
                                                                                     :gv
                                                                                     :xdot
                                                                                     :xdot1.2
                                                                                     :xdot1.4
                                                                                     :eps
                                                                                     :exr
                                                                                     :fig
                                                                                     :gd
                                                                                     :gd2
                                                                                     :gif
                                                                                     :gtk
                                                                                     :ico
                                                                                     :cmap
                                                                                     :ismap
                                                                                     :imap
                                                                                     :cmapx
                                                                                     :imap_np
                                                                                     :cmapx_np
                                                                                     :jpg
                                                                                     :jpeg
                                                                                     :jpe
                                                                                     :jp2
                                                                                     :json
                                                                                     :json0
                                                                                     :dot_json
                                                                                     :xdot_json
                                                                                     :pdf
                                                                                     :pic
                                                                                     :pct
                                                                                     :pict
                                                                                     :plain
                                                                                     :plain-ext
                                                                                     :png
                                                                                     :pov
                                                                                     :ps
                                                                                     :ps2
                                                                                     :psd
                                                                                     :sgi
                                                                                     :svg
                                                                                     :svgz
                                                                                     :tga
                                                                                     :tiff
                                                                                     :tif
                                                                                     :tk
                                                                                     :vml
                                                                                     :vmlz
                                                                                     :wbmp
                                                                                     :webp
                                                                                     :xlib
                                                                                     :x11]
                                                         :full true
                                                         :output nil}
                                           :executor (. (require :rust-tools/executors)
                                                        :termopen)
                                           :hover_actions {:auto_focus false
                                                           :border [["╭"
                                                                     :FloatBorder]
                                                                    ["─"
                                                                     :FloatBorder]
                                                                    ["╮"
                                                                     :FloatBorder]
                                                                    ["│"
                                                                     :FloatBorder]
                                                                    ["╯"
                                                                     :FloatBorder]
                                                                    ["─"
                                                                     :FloatBorder]
                                                                    ["╰"
                                                                     :FloatBorder]
                                                                    ["│"
                                                                     :FloatBorder]]}
                                           :inlay_hints {:auto false
                                                         :highlight :NonText
                                                         :max_len_align false
                                                         :max_len_align_padding 1
                                                         :only_current_line true
                                                         :other_hints_prefix "=> "
                                                         :parameter_hints_prefix "<- "
                                                         :right_align false
                                                         :right_align_padding 7
                                                         :show_parameter_hints true}
                                           :on_initialized (fn []
                                                             ((. (require :inlay-hints)
                                                                 :set_all)))
                                           :reload_workspace_from_cargo_toml true}})
((. (require :zk) :setup) {:lsp {:auto_attach {:enable true
                                               :filetypes [:markdown]}
                                 :config {:cmd [:zk :lsp]
                                          :name :zk
                                          :on_attach on-attach}}
                           :picker :telescope})
((. (require :zk.commands) :add) :ZkOrphans
                                 (fn [options]
                                   (set-forcibly! options
                                                  (vim.tbl_extend :force
                                                                  {:orphan true}
                                                                  (or options
                                                                      {})))
                                   ((. (require :zk) :edit) options
                                                            {:title "Zk Orphans (unlinked notes)"})))
((. (require :zk.commands) :add) :ZkGrep
                                 (fn [match-ctor]
                                   (var grep-str match-ctor)
                                   (var ___match___ nil)
                                   (if (or (= match-ctor nil) (= match-ctor ""))
                                       (do
                                         (vim.fn.inputsave)
                                         (set grep-str
                                              (vim.fn.input "Grep string: >"))
                                         (vim.fn.inputrestore)
                                         (set ___match___ {:match grep-str}))
                                       (= (type match-ctor) :string)
                                       (set ___match___ {:match grep-str}))
                                   ((. (require :zk) :edit) ___match___
                                                            {:mutli_select false
                                                             :title (.. "Grep: '"
                                                                        grep-str
                                                                        "'")})))
((. (require :gitsigns) :setup) {:signs {:add {:text "+"}
                                         :change {:text "~"}
                                         :changedelete {:text "~"}
                                         :delete {:text "_"}
                                         :topdelete {:text "‾"}}})
((. (require :lualine) :setup) {:inactive_sections {:lualine_a {}
                                                    :lualine_b {}
                                                    :lualine_c [{1 :filename
                                                                 :file_status true
                                                                 :path 1}]
                                                    :lualine_x [:location]
                                                    :lualine_y {}
                                                    :lualine_z {}}
                                :options {:icons_enabled true}
                                :sections {:lualine_a [:mode]
                                           :lualine_b [:branch
                                                       :diff
                                                       :diagnostics]
                                           :lualine_c [{1 :filename
                                                        :file_status true
                                                        :newfile_status false
                                                        :path 1
                                                        :symbols {:modified "[+]"
                                                                  :newfile "[New]"
                                                                  :readonly "[-]"
                                                                  :unnamed "[Unnamed]"}}]
                                           :lualine_x [:encoding
                                                       :fileformat
                                                       :filetype]
                                           :lualine_y [:progress]
                                           :lualine_z [:location]}})
((. (require :nvim-surround) :setup) {})
((. (require :tsql) :setup))
((. (require :fidget) :setup) {:align {:bottom true :right true}
                               :debug {:logging false :strict false}
                               :fmt {:fidget (fn [fidget-name spinner]
                                               (string.format "%s %s" spinner
                                                              fidget-name))
                                     :leftpad true
                                     :max_width 0
                                     :stack_upwards true
                                     :task (fn [task-name message percentage]
                                             (string.format "%s%s [%s]" message
                                                            (or (and percentage
                                                                     (string.format " (%s%%)"
                                                                                    percentage))
                                                                "")
                                                            task-name))}
                               :sources {:* {:ignore false}}
                               :text {:commenced :Started
                                      :completed :Completed
                                      :done "✔"
                                      :spinner :moon}
                               :timer {:fidget_decay 2000
                                       :spinner_rate 125
                                       :task_decay 1000}
                               :window {:blend 100
                                        :border :none
                                        :relative :editor
                                        :zindex nil}})	
