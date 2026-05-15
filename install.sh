#!/bin/bash
cd ~/.local

# neovim
wget https://github.com/neovim/neovim/releases/download/v0.12.1/nvim-linux-x86_64.tar.gz
mkdir nvim 
tar -xzvf nvim-linux-x86_64.tar.gz -C nvim --strip-components=1
ln -s ~/.local/nvim/bin/nvim ~/.local/bin/nvim
rm -rf ~/.local/nvim-linux-x86_64.tar.gz

# ripgrep for grep searching
wget https://github.com/BurntSushi/ripgrep/releases/download/15.1.0/ripgrep-15.1.0-x86_64-unknown-linux-musl.tar.gz 
tar -xzvf ripgrep-15.1.0-x86_64-unknown-linux-musl.tar.gz 
mv ~/.local/ripgrep-15.1.0-x86_64-unknown-linux-musl/rg ~/.local/bin/rg 
rm -rf ~/.local/ripgrep-15.1.0-x86_64-unknown-linux-musl.tar.gz
rm -rf ~/.local/ripgrep-15.1.0-x86_64-unknown-linux-musl

# uv and python for some lsps / formatters (clang-format)
wget -qO- https://astral.sh/uv/install.sh | sh
uv python install 3.13 --default

# n for nodejs and npm for some lsps/ formatters (copilot)
curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s install lts \

# tree-sitter for better syntax highlighting
# for Ubuntu 22.04 use 0.25.x
# for Ubuntu 24.04 use 0.26.x
npm -g install tree-sitter-cli@0.25

# xclip for system clipboard
wget https://github.com/astrand/xclip/archive/refs/tags/0.13.tar.gz
tar -xvzf xclip-0.13.tar.gz
cd xclip-0.13
./configure --prefix=~/.local --disable-shared
make
make install
cd ..
rm -rf ~/.local/xclip-0.13.tar.gz
rm -rf ~/.local/xclip-0.13
