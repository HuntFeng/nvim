#!/bin/bash
# run this script as root

# xclip for system clipboard
# ripgrep for searching
# fzf for fuzzy find
# python for some lsps / formatters (clang-format)
# n for nodejs and npm for some lsps/ formatters (copilot)
apt-get update \
&& cd /opt \
&& wget https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.tar.gz \
&& mkdir nvim \
&& tar -xzvf nvim-linux-x86_64.tar.gz -C nvim --strip-components=1 \
&& ln -s /opt/nvim/bin/nvim /usr/bin/nvim \
&& rm -rf /opt/nvim-linux-x86_64.tar.gz
&& wget https://github.com/junegunn/fzf/releases/download/v0.66.1/fzf-0.66.1-linux_amd64.tar.gz \
&& tar -xvzf fzf-0.66.1-linux_amd64.tar.gz \
&& mv fzf /usr/bin \
&& rm fzf-0.66.1-linux_amd64.tar.gz \
&& apt-get install -y xclip \
&& apt-get install -y ripgrep \
&& apt-get install -y python3 python3-pip python3-venv \
&& curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s install lts \

