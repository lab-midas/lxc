#!/bin/bash

# General
sudo apt -y install gcc
sudo apt -y install environment-modules
sudo apt -y install qt5-default

# Install pyenv/python
sudo apt -y install make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
sudo rm -r $HOME/.pyenv
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> $HOME/.bashrc
echo 'eval "$(pyenv init -)"' >> $HOME/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"' >> $HOME/.bashrc
source "$HOME/.bashrc"

# Set env variables manually, sometimes .bashrc is not used
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Install python version
pyenv install 3.7.4
pyenv global 3.7.4
pip install --upgrade pip

# Install desktop and x2goserver
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:x2go/stable
sudo apt update -y
sudo apt install -y x2goserver x2goserver-xsession
sudo apt install -y xfce4
sudo apt install -y xfce4-terminal

# Install Software
sudo snap install --classic gitkraken
sudo snap install --classic pycharm-community

chrome_deb=google-chrome-stable_current_amd64.deb
wget  https://dl.google.com/linux/direct/$chrome_deb -P $HOME
sudo apt install -y $HOME/$chrome_deb
rm $HOME/$chrome_deb

# Set environment variables
echo 'export PATH="/home/ubuntu/.local/bin:$PATH"' >> ~/.bashrc
# search bash history via *CTRL + up/down arrow*
touch $HOME/.bash_aliases
echo "bind '\"\e[1;5A\":history-search-backward' " >> ~/.bash_aliases
echo "bind '\"\e[1;5B\":history-search-forward'" >> ~/.bash_aliases
source ~/.bashrc


