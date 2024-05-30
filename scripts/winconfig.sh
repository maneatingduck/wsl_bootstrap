#!/usr/bin/env sh
# desc: copies ssh keys and gitconfig from windows, sets prompt and case insensitive completion
# get ssh keys
# winuser=$(cmd.exe /c "echo %USERNAME%")
winuser=$(powershell.exe -NoProfile -NonInteractive -Command "\$Env:UserName")
winuser=$(echo $winuser|sed 's#\r##g')
echo "windows user name '$winuser'"
# if [ $winuser == "" || $false ]; then 
#   echo "windows username not detected, please enter it"&&read winuser
# else
#     echo $winuser
# fi
if [ ! -f ~/.inputrc ]; then echo '$include /etc/inputrc' > ~/.inputrc; fi
# Add shell-option to ~/.inputrc to enable case-insensitive tab completion
echo 'set completion-ignore-case On' >> ~/.inputrc

cd ~
ln -s /mnt/c/Users/$winuser/
cp -rv $winuser/.ssh .
cp -rv $winuser/.gitconfig .
chmod 700 .ssh/id_rsa
cat << \EOF >> ~/.bashrc
export PS1="\u@\$WSL_DISTRO_NAME:\[\033[32m\]\w\[\033[33m\]\$(GIT_PS1_SHOWUNTRACKEDFILES=1 GIT_PS1_SHOWDIRTYSTATE=1 GIT_PS1_DESCRIBE_STYLE=branch GIT_PS1_SHOWCOLORHINTS=1 __git_ps1)\[\033[00m\]$ "
EOF
. ~/.bashrc
