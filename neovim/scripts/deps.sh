#!/usr/bin/env bash

# This file installs dependencies needed for the Neovim plugins
echo "Please run this in sudo mode for sudo apt* commands"

# Pip and Python3
if [ ! python3 --version ] ; then
    PYTHON_3=${PYTHON_3:-"python3.10"}
    apt install $PYTHON_3
    $PYTHON_3 -m ensurepip --upgrade
    $PYTHON_3 -m pip install --upgrade pip
fi

# Neovim vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'


