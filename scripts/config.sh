#!/usr/bin/env sh
# desc: set prompt and completion-ignore-case

ln -sn "$(cd . && pwd)" ~/ubuntu_bs 
if [ ! -f ~/.inputrc ]; then echo '$include /etc/inputrc' > ~/.inputrc; fi
# Add shell-option to ~/.inputrc to enable case-insensitive tab completion
echo 'set completion-ignore-case On' >> ~/.inputrc

cat << \EOF >> ~/.bashrc
export PS1="\u@\$WSL_DISTRO_NAME:\[\033[32m\]\w\[\033[33m\]\$(GIT_PS1_SHOWUNTRACKEDFILES=1 GIT_PS1_SHOWDIRTYSTATE=1 GIT_PS1_DESCRIBE_STYLE=branch GIT_PS1_SHOWCOLORHINTS=1 __git_ps1)\[\033[00m\]$ "
EOF
printf 'updated bashrc\n'

