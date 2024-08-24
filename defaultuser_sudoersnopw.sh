# Make sure your user is the default wsl user, as an imported image won't have the correct registry key set. 
printf '\n[user]\ndefault=%s\n' $USER | sudo tee -a /etc/wsl.conf
# Also add your user to sudoers with no password
printf '\n%s ALL=(ALL) NOPASSWD: ALL\n' $USER | sudo tee -a /etc/sudoers
