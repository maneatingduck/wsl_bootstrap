echo "bootstrap: updating system"
cd ~
sudo apt-get update
sudo apt-get upgrade -y

# get ssh keys
ln -s /mnt/c/Users/aa303/
cp -rv aa303/.ssh .
chmod 700 .ssh/id_rsa
# ln -s /mnt/c/Users/aa303/.ssh
echo "bootstrap: install brew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo "bootstrap: install build-essential"
sudo apt-get install build-essential -y

(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/$(whoami)/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install chezmoi
chezmoi init git@gitlab.intility.com:aa303/dotfiles.git

cat << \EOF >> ~/Brewfile
tap "homebrew/bundle"
brew "chezmoi"
brew "k9s"
brew "kubernetes-cli"
brew "krew"
EOF

cd ~
brew bundle
kubectl completion bash >~/.kubectl_completion

cat << \EOF >> ~/.bashrc
if [ -f ~/.kubectl_completion ]; then
    . ~/.kubectl_completion
fi
alias k=kubectl
complete -o default -F __start_kubectl k
EOF

# get OC
cd /var/tmp
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz -O oc.tar.gz
tar -xzvf oc.tar.gz oc
sudo cp -fv oc /usr/local/bin/oc
cd ~
oc completion bash > ~/oc_completion_bash

cat << \EOF >> ~/.bashrc
if [ -f ~/.oc_completion_bash ]; then
    . ~/.oc_completion_bash
fi
EOF

source ~/.bash_rc
# dotnet the ubuntu way
sudo apt remove 'dotnet*' 'aspnet*' 'netstandard*'

sudo cat << \EOF >> /etc/apt/preferences
Package: dotnet* aspnet* netstandard*
Pin: origin "packages.microsoft.com"
Pin-Priority: -10
EOF

# Get Ubuntu version
declare repo_version=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi)

# Download Microsoft signing key and repository
wget https://packages.microsoft.com/config/ubuntu/$repo_version/packages-microsoft-prod.deb -O packages-microsoft-prod.deb

# Install Microsoft signing key and repository
sudo dpkg -i packages-microsoft-prod.deb

# Clean up
rm packages-microsoft-prod.deb

# Update packages
sudo apt update

dotnet tool install --global dotnet-ef
sudo apt install dotnet-sdk-8.0 -y
sudo dotnet workload update
cat << \EOF >> ~/.bashrc
# Add .NET Core SDK tools
export PATH="$PATH:/home/$(whoami)/.dotnet/tools"
EOF

. ~/.bashrc

#remove snap
echo "Removing snap..."
# Stop the daemon
sudo systemctl disable --now snapd
# Uninstall
sudo apt purge -y snapd
# Tidy up dirs
sudo rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd ~/snap
# Stop it from being reinstalled by 'mistake' when installing other packages
cat << EOF | sudo tee -a /etc/apt/preferences.d/no-snap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
sudo chown root:root /etc/apt/preferences.d/no-snap.pref
# done
echo "Snap removed"
