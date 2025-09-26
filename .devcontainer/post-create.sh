#!/usr/bin/env bash

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

sudo apt-get update
sudo apt-get -y install \
  apt-transport-https \
  ca-certificates \
  gnupg \
  curl \
  python3 \
  python3-pip \
  python3-venv \
  git \
  sudo \
  bsdextrautils \
  build-essential \
  google-cloud-cli
sudo rm -rf /var/lib/apt/lists/*

# Install brew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# BASH
echo >> /home/$USER/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/$USER/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# ZSH
sed -i 's/plugins=(git)/plugins=(git brew direnv docker-compose docker gcloud gh golang helm k9s kind kubectl node npm opentofu pip pre-commit python sudo uv)/' /home/$USER/.zshrc
sed -i '/source $ZSH\/oh-my-zsh.sh/i eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' /home/$USER/.zshrc
echo >> /home/$USER/.bashrc
echo 'autoload -Uz compinit' >> /home/$USER/.zshrc
echo 'compinit' >> /home/$USER/.zshrc

brew update
brew bundle --file=.devcontainer/Brewfile
brew cleanup --prune=all

mkdir -p ~/.zfunc
$(brew --prefix)/bin/cog generate-completions zsh > ~/.zfunc/_cog

sudo cp -R /mnt/tmp/.ssh/* ~/.ssh
sudo chown -R $(whoami):$(whoami) ~ || true ?>/dev/null
sudo chmod 400 ~/.ssh/*

echo "*******************************************************"
echo "*                                                     *"
echo "* Close and reopen ALL your terminals to refresh the  *"
echo "* environment for auto-completion                     *"
echo "*                                                     *"
echo "*******************************************************"
