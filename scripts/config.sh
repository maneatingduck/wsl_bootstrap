#!/usr/bin/bash
# desc: set prompt and completion-ignore-case
if [[ -f ~/bsconfig ]]; then 
    echo "Config has alreay been applied"
else
    printf 'Adding users to sudoers with no password\n'
    printf '\n%s ALL=(ALL) NOPASSWD: ALL\n' $USER | sudo tee -a /etc/sudoers

    printf "Writing /etc/wsl.conf\n"
    printf '[boot]\nsystemd=true\n'  | sudo tee  /etc/wsl.conf >/dev/null
    printf '[user]\ndefault=%s\n' $USER | sudo tee -a /etc/wsl.conf >/dev/null

    ln -snf "$(cd . && pwd)" ~/ubuntu_bs 
    if [ ! -f ~/.inputrc ]; then echo '$include /etc/inputrc' > ~/.inputrc; fi
    # Add shell-option to ~/.inputrc to enable case-insensitive tab completion
    echo 'set completion-ignore-case On' >> ~/.inputrc

cat << \EOF >> ~/.bashrc
export PS1="\u@\$WSL_DISTRO_NAME:\[\033[32m\]\w\[\033[33m\]\$(GIT_PS1_SHOWUNTRACKEDFILES=1 GIT_PS1_SHOWDIRTYSTATE=1 GIT_PS1_DESCRIBE_STYLE=branch GIT_PS1_SHOWCOLORHINTS=1 __git_ps1)\[\033[00m\]$ "
EOF
printf 'updated bashrc\n'
    touch ~/bsconfig
fi