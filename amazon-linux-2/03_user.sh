#!/bin/bash

. ./lib

PATH="/usr/local/bin:$PATH"

echo "Creating a new user"
useradd -g wheel ${USERNAME}
echo "lowply ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/lowply
echo "Defaults env_keep += \"SSH_AUTH_SOCK\"" | tee /etc/sudoers.d/ssh_auth_sock
chmod 440 /etc/sudoers.d/lowply
chmod 440 /etc/sudoers.d/ssh_auth_sock

echo "Adding a pubkey"
su ${USERNAME} -lc "mkdir ~/.ssh"
su ${USERNAME} -lc "curl -s -o ~/.ssh/authorized_keys https://github.com/lowply.keys"
su ${USERNAME} -lc "chmod 600 ~/.ssh/authorized_keys"

echo "Installing ghq"
su ${USERNAME} -lc "mkdir ~/go" 
su ${USERNAME} -lc "go get github.com/x-motemen/ghq"

echo "Install dotfiles"
su ${USERNAME} -lc "~/go/bin/ghq get https://github.com/lowply/dotfiles.git"
su ${USERNAME} -lc "~/ghq/github.com/lowply/dotfiles/install do"

yum -y install crontabs
echo "0 7 * * * /home/${USERNAME}/.ghq/github.com/lowply/dotfiles/bin/pull_dotfiles.sh >/dev/null" > /var/spool/cron/${USERNAME}
chown ${USERNAME}:wheel /var/spool/cron/${USERNAME}
chmod 600 /var/spool/cron/${USERNAME}
