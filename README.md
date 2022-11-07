# dotfiles

Contains my configurations for the software I use.

I'm looking to move forward to configuration with NixOS, but until I get
a bit more experiment on NixOS, I'll keep this repository as simple as possible.

## Nix

Monorepo that contains my commonly used personal environments.
I hope to incorporate my configs at [gh:pegasust/dotfiles](https://github.com/pegasust/dotfiles)
onto this repo for quick env setup (especially devel) on new machines.

## How do I apply these config

- I will always first clone this repository, preferably from local source before
going from the github. `git clone https://github.com/pegasust/dotfiles`

### neovim

My main text editor. It's based on `vim`, but stays loyal to `lua` ecosystem

- Config file: `./nvim/init.lua`
- Command: `ln [-s] $PWD/nvim/init.lua ~/.config/nvim`

#### Notes

- Ensure that neovim is installed and invocable by `nvim`.
- My config based on rather experimental version of`nvim` (>=0.7.2)
- For information on installing neovim, visit their [github page](https://github.com/neovim/neovim/wiki/Installing-Neovim)

### tmux

Terminal multiplexor. Allows creating persistent sessions and multiple terminal windows
from one terminal.

- Config file: `./tmux/.tmux.conf`
- Command: `ln [-s] $PWD/tmux/.tmux.conf ~/.tmux.conf`

#### Notes

- Unsure if the minimum version of tmux. I have had an ancient HPC server
that does not respond well to one of the config lines.

### zk

Zettelkasten notebook. This is how I document my learning and reflect on myself
via writing and typing.

I am in the process of moving away from Obsidian so that I can write ZK notes
text-editor agnostically.

- Config file: `zk/config.toml`
- Command: `ln [-s] $PWD/zk/config.toml ~/.config/zk/config.toml`

- Templates: `zk/templates/`
- Command: `ln -s $PWD/zk/templates ~/.config/zk/templates`


