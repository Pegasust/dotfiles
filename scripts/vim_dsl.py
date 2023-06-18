#!/usr/bin/env python3 # A simple playground to explore vim plugins that are available in nixpkgs

import csv
import urllib.request
from io import StringIO
import sqlite3

UPSTREAM_CSV = "https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/applications/editors/vim/plugins/vim-plugin-names"


def load_csv(url):
    with urllib.request.urlopen(url) as response:
        data = response.read().decode()
        return csv.DictReader(StringIO(data))


class VimPlugins:
    def __init__(self, url: str, sqlite: str = ":memory:"):
        self.conn = sqlite3.connect(sqlite)
        csv_data = load_csv(url)
        fieldnames = csv_data.fieldnames or ["repo", "branch", "alias"]

        cur = self.create_table()
        for row in csv_data:
            fields = ", ".join(f'"{row[field]}"' for field in fieldnames)
            cur.execute(f"INSERT INTO {self.table_name()} VALUES ({fields})")

        self.conn.commit()

    def create_table(self, cursor=None):
        cur = self.conn.cursor() if not cursor else cursor
        cur.execute(f'''
        CREATE TABLE {self.table_name()} (
            "repo" TEXT,
            "branch" TEXT,
            "alias" TEXT
        );
        ''')
        return cur

    def table_name(self):
        return "vim_plugins"

    def query(self, query: str):
        return self.conn.cursor().execute(query).fetchall()


def vim_plugin_slug(name: str):
    return name.replace(".", "-").lower()


def name_from_repo(repo: str):
    spl = repo.split("/")
    return vim_plugin_slug(spl[-1] or spl[-2])


if __name__ == "__main__":
    # REPL zone
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
    need_install_plugins = [plugin.strip() for plugin in need_install_plugins if plugin.strip()]

    # Create the GitHub URL list
    need_install_plugins_gh = [
        f"https://github.com/{plugin}/".lower() for plugin in need_install_plugins if not plugin.startswith(("~", "."))]

    # Get the values from the database
    values = vp.query(f"SELECT LOWER(repo), alias from {vp.table_name()}")

    # Check if the repo is in the list of plugins
    need_install = [
        vim_plugin_slug(alias) if alias else name_from_repo(repo) for repo, alias in values if repo in need_install_plugins_gh]

    print("need_install")
    print("\n".join(need_install))

    # Check if the repo is not in the list
    repos = [repo for repo, _ in values]
    not_in_repo = [name_from_repo(gh) for gh in need_install_plugins_gh if gh not in repos]
    print("not in repo", not_in_repo) # nvim-yati, yang-vim, Comment-nvim, inlay-hints-nvim, hlargs-nvim, vim-caser, gruvbox-community
    

