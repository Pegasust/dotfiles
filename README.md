# dotfiles

Contains my configurations for the software I use.

I'm looking to move forward to configuration with NixOS, but until I get
a bit more experiment on NixOS, I'll keep this repository as simple as possible.

- As of 2023-06-07, I have little interest in keeping configurations 
([`init.lua`](./native_configs/neovim/init.lua), [`sshconfig`](./native_configs/ssh/config),...) 
to be idempotent for Nix and non-Nix targets.

## Bleed-first development

NOTE: this is extremely bleeding edge with many different branches that are probably
stale. This is because I'm breaking all the time and wanted my `master` branch
to be simply "minimally" available, regardless of what features I implemented later
on.

Currently, `master` is probably not as stable as we all want it to be.

`bleed` was created as I moved onto using [`gh:divnix/std`](https://github.com/divnix/std)
which introduced more explorations to make it backward compatible

`lean` was created in the process of merging `bleed` back onto `master`. Couple 
of my infra on Linode are spun down due to Akamai's increased cost, so I try 
to keep everything lean, while having an available branch (`bleed`) to look 
back to if I need to do anything fancy. `lean` here means it's minimal to the
best of its ability by having only functional code.


## Nix

Monorepo that contains my commonly used personal environments.
I hope to incorporate my configs at [gh:pegasust/dotfiles](https://github.com/pegasust/dotfiles)
onto this repo for quick env setup (especially devel) on new machines.

## How do I apply these config

- Clone and nixify

### neovim

My main text editor. It's based on `vim`, but stays loyal to `lua` ecosystem

- Config file: `./nvim/init.lua`
- Command: `ln [-s] $PWD/nvim/init.lua ~/.config/nvim`

#### Notes

- Ensure that neovim is installed and invocable by `nvim`.
- For information on installing neovim, visit their [github page](https://github.com/neovim/neovim/wiki/Installing-Neovim)

### tmux

Terminal multiplexor. Allows creating persistent sessions and multiple terminal windows
from one terminal.

- Config file: `./tmux/tmux.conf`
- Command: `ln [-s] $PWD/tmux/tmux.conf ~/.tmux.conf`
  - Or `ln [-s] $PWD/tmux/tmux.conf ~/.config/tmux/tmux.conf` (hardcoded, `$XDG_CONFIG_HOME` is ignored)

#### Notes

- Unsure of the minimum version of tmux. I have had an ancient HPC server
that does not respond well to one of the config lines.

### zk

Zettelkasten notebook. This is how I document my learning and reflect on myself
via writing and typing.

I am in the process of moving away from Obsidian so that I can write ZK notes
text-editor agnostically.

#### mickael-menu/zk


- Config file: `zk/config.toml`
- Command: `ln [-s] $PWD/zk/config.toml ~/.config/zk/config.toml`

- Templates: `zk/templates/`
- Command: `ln -s $PWD/zk/templates ~/.config/zk/templates`

Note (2023-06-07): I'm now using a mix of nvim-zk with Notion. I'm still figuring out
a centralize place to put my notes and use it to do some knowledge graph magic

NOTE (2023-06-18): I used `mickael-menu/zk` for some time, but have found myself 
resort to notion due to the need for easier linking (just copy-paste onto 
selected note) where as I need to:

- `cS]` to encapsulate the selection with `[]`, then do `(<C-v>`. Too many keystrokes.

On retrospect, I could probably remap this workflow to `<LocalLeader>el"`:

Though, I want to just develop my own solution with 
[`nucliadb`](https://github.com/nuclia/nucliadb) and 
[`h2ogpt`](https://github.com/h2oai/h2ogpt)

## Troubleshoots

### My MacOS just updated, `nix` is no-longer here

- An easy fix is to add the following  to the **bottom** of `/etc/zshrc`

```sh
# Nix {{{
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# }}} 
```

- Otherwise, consult [`gh-gist:meeech/a_help-osx-borked-my-nix.md`](https://gist.github.com/meeech/0b97a86f235d10bc4e2a1116eec38e7e)


