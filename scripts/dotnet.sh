#!/usr/bin/env sh
# desc: installs latest dotnet
echo dotnet the ubuntu way
sudo apt remove 'dotnet*' 'aspnet*' 'netstandard*' -y

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
dotnet tool install --global dotnet-ef
cat << \EOF >> ~/.bashrc
# Add .NET Core SDK tools
export PATH="$PATH:/home/$(whoami)/.dotnet/tools"
EOF


