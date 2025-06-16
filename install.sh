#!/bin/bash
# install xclip for system clipboard
sudo apt-get install -y xclip
# install ripgrep for searching in files
sudo apt-get install -y ripgrep
# install nodejs and npm for copilot 
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash - && sudo apt-get install -y nodejs
# install neovim
cd /opt
sudo wget https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.tar.gz
sudo mkdir nvim && sudo tar -xzvf nvim-linux-x86_64.tar.gz -C nvim --strip-components=1
sudo ln -s /opt/nvim/bin/nvim /usr/bin/nvim

