#!/bin/bash
sudo mkdir -p /root/.local/share/nvim/site/autoload
mkdir -p ${HOME}/.config/nvim/
gedit ${HOME}/.config/nvim/init.vim
sudo rm /etc/xdg/nvim/sysinit.vim
sudo ln -s ${HOME}/.config/nvim/init.vim /etc/xdg/nvim/sysinit.vim
sudo ln -s ${HOME}/.local/share/nvim/site/autoload/plug.vim /root/.local/share/nvim/site/autoload/plug.vim

