# Offset Vim Plugins onto nix packer

The current [`scripts/vim.dsl`](../scripts/vim.dsl) grabs the upstream supported vim plugins
onto a sqlite database to be stored in memory. We could perform some data exploration via this database 

## Example: Explore which plugins should be added to `neovim.nix`

Gather list of plugins need to be added. This can be done simply by adding 
a print statement on `WPlug` in `../native_configs/neovim/init.lua` then run neovim
to collect it.

```lua
-- as of git://./dotfiles.git#a6c979c6
local function WPlug(plugin_path, ...)
  local plugin_name = string.lower(plugin_path:match("/([^/]+)$"))
  if not installed_plugins[plugin_name] then
    -- NOTE: Add print statement to get which plugin is still being
    -- plugged at runtime
    print("Plugging "..plugin_path)
    Plug(plugin_path, ...)
  end
end
```

We can then use `vim_dsl.py`

```py
  vp = VimPlugins(UPSTREAM_CSV)
  need_install_plugins = """
tjdevries/nlua.nvim
yioneko/nvim-yati
nathanalderson/yang.vim
numToStr/Comment.nvim
lewis6991/gitsigns.nvim
tpope/vim-fugitive
williamboman/mason.nvim
williamboman/mason-lspconfig.nvim
TimUntersberger/neogit
folke/trouble.nvim
tpope/vim-dispatch
clojure-vim/vim-jack-in
radenling/vim-dispatch-neovim
gennaro-tedesco/nvim-jqx
kylechui/nvim-surround
simrat39/inlay-hints.nvim
gruvbox-community/gruvbox
nvim-lualine/lualine.nvim
lukas-reineke/indent-blankline.nvim
kyazdani42/nvim-web-devicons
m-demare/hlargs.nvim
folke/todo-comments.nvim
nvim-treesitter/playground
saadparwaiz1/cmp_luasnip
L3MON4D3/LuaSnip
arthurxavierx/vim-caser
~/local_repos/ts-ql
  """.split()
  need_install_plugins = [plugin.strip() for plugin in plugins_raw if plugin.strip()]

  # Create the GitHub URL list
  need_install_plugins_gh = [
    f"https://github.com/{plugin}/".lower() for plugin in need_install_plugins if not plugin.startswith(("~", "."))]

  # Get the values from the database
  values = vp.query(f"SELECT LOWER(repo), alias from {vp.table_name()}")

  # Check if the repo is in the list of plugins
  need_install = [
    vim_plugin_slug(alias) if alias else name_from_repo(repo) for repo, alias in values if repo in need_install_plugins_gh]

  print("need_install", "\n".join(need_install))

  # Check if the repo is not in the list
  repos = [repo for repo, _ in values]
  not_in_repo = [name_from_repo(gh) for gh in need_install_plugins_gh if gh not in repos]
  print("not in repo", not_in_repo) # nvim-yati, yang-vim, Comment-nvim, inlay-hints-nvim, hlargs-nvim, vim-caser, gruvbox-community
```

This should print out
```
need_install
cmp_luasnip
comment-nvim
gitsigns-nvim
gruvbox-community
indent-blankline-nvim
lualine-nvim
luasnip
mason-lspconfig-nvim
mason-nvim
neogit
nlua-nvim
nvim-jqx
nvim-surround
nvim-web-devicons
playground
todo-comments-nvim
trouble-nvim
vim-dispatch
vim-dispatch-neovim
vim-fugitive
vim-jack-in
not in repo ['nvim-yati', 'yang-vim', 'inlay-hints-nvim', 'hlargs-nvim', 'vim-caser']
```

Given this list, we could safely add to `neovim.nix`

```nix
programs.neovim.plugins = 
 let inherit (pkgs.vimPlugins)
    need_install
    cmp_luasnip
    comment-nvim
    gitsigns-nvim
    gruvbox-community
    indent-blankline-nvim
    lualine-nvim
    luasnip
    mason-lspconfig-nvim
    mason-nvim
    neogit
    nlua-nvim
    nvim-jqx
    nvim-surround
    nvim-web-devicons
    playground
    todo-comments-nvim
    trouble-nvim
    vim-dispatch
    vim-dispatch-neovim
    vim-fugitive
    vim-jack-in
 ;in [
    need_install
    cmp_luasnip
    comment-nvim
    gitsigns-nvim
    gruvbox-community
    indent-blankline-nvim
    lualine-nvim
    luasnip
    mason-lspconfig-nvim
    mason-nvim
    neogit
    nlua-nvim
    nvim-jqx
    nvim-surround
    nvim-web-devicons
    playground
    todo-comments-nvim
    trouble-nvim
    vim-dispatch
    vim-dispatch-neovim
    vim-fugitive
    vim-jack-in
  
 ];
```


TODO:
- [ ] Source the plugins directly
- [ ] Add 'frozen' to each of these plugin
- [ ] Pin plugins separately from `neovim.nix`
- [ ] Find a better way to `inherit` with list comprehension
- [ ] Create alert & notification channel for this, ideally via Discord channel
- [ ] Even better, just put it in email with some labels
- [ ] Better end-to-end design that take even deeper account to gruvbox-community and such

