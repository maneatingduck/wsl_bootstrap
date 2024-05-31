#!/usr/bin/env sh
# desc: install brew, which is a prerequisite for several other actions
# postreq: cleanbrew
echo Brew
cd ~
echo "bootstrap: install brew"

yes "" | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo "bootstrap: install build-essential"
sudo apt-get install build-essential -y

(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# brew install chezmoi
# chezmoi init git@gitlab.intility.com:aa303/dotfiles.git
export HOMEBREW_NO_AUTO_UPDATE=1
if [ ! -f ~/Brewfile ]; then
cat << \EOF >> ~/Brewfile
tap "homebrew/bundle"
EOF
fi
cat << \EOF >> ~/Brewfile
EOF
# yes ''|brew cleanup --prune=all
