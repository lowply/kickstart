#!/bin/bash

. ./lib

echo "Creating a new user"
useradd -g wheel ${USERNAME}
echo "lowply ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/lowply
echo "Defaults env_keep += \"SSH_AUTH_SOCK\"" | tee /etc/sudoers.d/ssh_auth_sock
chmod 440 /etc/sudoers.d/lowply
chmod 440 /etc/sudoers.d/ssh_auth_sock

echo "Adding a pubkey"
su ${USERNAME} -c "mkdir ~/.ssh"
su ${USERNAME} -c "curl -o ~/.ssh/authorized_keys https://github.com/lowply.keys"
su ${USERNAME} -c "chmod 600 ~/.ssh/authorized_keys"

su ${USERNAME} -c "go get github.com/x-motemen/ghq"

echo "Install dotfiles"
su ${USERNAME} -c "/bin/git clone https://github.com/lowply/dotfiles.git ~/dotfiles"
su ${USERNAME} -c "~/dotfiles/bin/install.sh"

echo "Creating ~/go"
su ${USERNAME} -c "mkdir ~/go" 

yum -y install crontabs
echo "0 7 * * * /home/${USERNAME}/.ghq/github.com/lowply/dotfiles/bin/pull_dotfiles.sh >/dev/null" > /var/spool/cron/${USERNAME}
chown ${USERNAME}:wheel /var/spool/cron/${USERNAME}
chmod 600 /var/spool/cron/${USERNAME}
