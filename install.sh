#!/bin/bash
# run this script as root

# xclip for system clipboard
# ripgrep for grep searching
# fd for file searching (need to be renamed to fd to avoid conflict with the fd command in coreutils)
# python for some lsps / formatters (clang-format)
# n for nodejs and npm for some lsps/ formatters (copilot)
# tree-sitter for better syntax highlighting 
apt-get update \
&& cd /opt \
&& wget https://github.com/neovim/neovim/releases/download/v0.12.1/nvim-linux-x86_64.tar.gz \
&& mkdir nvim \
&& tar -xzvf nvim-linux-x86_64.tar.gz -C nvim --strip-components=1 \
&& ln -s /opt/nvim/bin/nvim /usr/bin/nvim \
&& rm -rf /opt/nvim-linux-x86_64.tar.gz
&& apt-get install -y xclip \
&& apt-get install -y fd-find \
&& ln -s $(which fdfind) ~/.local/bin/fd \ 
&& apt-get install -y ripgrep \
&& apt-get install -y python3 python3-pip python3-venv \
&& curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s install lts \
&& wget https://github.com/tree-sitter/tree-sitter/releases/download/v0.26.8/tree-sitter-cli-linux-x86.zip \
&& unzip tree-sitter-cli-linux-x86.zip \
&& mv tree-sitter-cli-linux-x86/tree-sitter /usr/bin/treesitter \

