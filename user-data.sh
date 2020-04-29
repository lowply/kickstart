#!/bin/bash

set -e

PATH="/usr/local/bin:$PATH"

abort(){
    echo "${1}"
    exit 1
}

debug(){
    echo "$(date): ${1}" >> /var/log/user-data.log
}

# =========================================
# Packages
# =========================================

run_packages(){
    debug "Running yum update"
    yum -y update

    debug "Installing dev tools"
    yum -y groupinstall --with-optional "Development Tools"

    debug "Installing essential packages"
    yum -y install \
        perl-devel \
        expat-devel \
        readline-devel \
        sqlite-devel \
        bzip2-devel \
        zlib-devel \
        openssl-devel \
        bash-completion \
        xmlto \
        bind-utils \
        dstat \
        net-tools \
        nginx \
        vim-enhanced \
        mariadb \
        mariadb-server \
        mariadb-devel

    debug "Installing python"
    if [ -n "${IS_CL}" ]; then
        yum -y install python36
    else
        yum -y install python3
    fi

    debug "Installing Docker / Podman"
    if [ -n "${IS_CL}" ]; then
        yum -y install podman podman-docker
    else
        yum -y install docker
    fi

    debug "Installing epel"
    if [ -n "${IS_CL}" ]; then
        rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    else
        amazon-linux-extras install epel
    fi

    ln -s /usr/share/git-core/contrib/diff-highlight /usr/local/bin
}

# =========================================
# SSH port
# =========================================

run_ssh(){
    debug "Change SSH port"
    sed -i 's/#Port 22/Port 1417/' /etc/ssh/sshd_config
    if [ -n "${IS_CL}" ]; then
        sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
        sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    fi
    systemctl restart sshd
}

# =========================================
# Date
# =========================================

run_date(){
    debug "Configure date"
    timedatectl set-timezone Asia/Tokyo
}

# =========================================
# Go
# =========================================

run_go(){
    debug "Install Go"
    GO_VERSION="1.14.2"

    uname -a | grep -q x86_64 && GO_ARCH="amd64"
    uname -a | grep -q aarch64 && GO_ARCH="arm64"

    if [ -n "${GO_ARCH}" ]; then
        curl -OL https://dl.google.com/go/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
        tar xzf go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
        mv go /usr/local/go
        ln -s /usr/local/go/bin/go* /usr/local/bin/
    fi

    mkdir ~/go 
}

# =========================================
# User
# =========================================

run_user(){
    USERNAME="lowply"

    debug "Creating a new user: ${USERNAME}"
    useradd -g wheel ${USERNAME}
    echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}
    echo "Defaults env_keep += \"SSH_AUTH_SOCK\"" > /etc/sudoers.d/ssh_auth_sock
    chmod 440 /etc/sudoers.d/${USERNAME}
    chmod 440 /etc/sudoers.d/ssh_auth_sock

    debug "Adding a pubkey"
    su ${USERNAME} -lc "mkdir ~/.ssh && chmod 700 ~/.ssh"
    su ${USERNAME} -lc "curl -s -o ~/.ssh/authorized_keys https://github.com/lowply.keys"
    su ${USERNAME} -lc "chmod 600 ~/.ssh/authorized_keys"
}

# =========================================
# crontabs
# =========================================

run_dotfiles(){
    debug "Installing ghq"
    go get github.com/x-motemen/ghq

    debug "Install dotfiles"
    ~/go/bin/ghq get https://github.com/lowply/dotfiles.git
    ~/ghq/github.com/lowply/dotfiles/install do

    echo '0 7 * * * ${HOME}/ghq/github.com/lowply/dotfiles/bin/pull_dotfiles.sh >/dev/null' >> /var/spool/cron/root
    chmod 600 /var/spool/cron/root
}

# =========================================
# node
# =========================================

run_node(){
    debug "Install Node"
    NODE_VERSION="12.16.1"

    uname -a | grep -q x86_64 && NODE_ARCH="x64"
    uname -a | grep -q aarch64 && NODE_ARCH="arm64"

    if [ -n "${NODE_ARCH}" ]; then
        curl -OL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz
        tar xJf node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz
        mv node-v${NODE_VERSION}-linux-${NODE_ARCH} /usr/local/node
        ln -s /usr/local/node/bin/* /usr/local/bin/
    fi
}

# =========================================
# tmux
# =========================================

run_tmux(){
    TMUX_VERSION="3.1"

    debug "Install tmux"
    yum -y install libevent-devel ncurses-devel
    cd /usr/local/src
    curl -OL https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
    tar xzf tmux-${TMUX_VERSION}.tar.gz
    cd tmux-${TMUX_VERSION}
    ./configure --prefix=/usr/local/tmux
    make && make install
    ln -s /usr/local/tmux/bin/tmux /usr/local/bin/
}

# =========================================
# munin
# =========================================

run_munin(){
    debug "Install Munin"

    if [ -n "${IS_CL}" ]; then
        dnf config-manager --set-enabled PowerTools
    fi

    yum -y install munin --enablerepo=epel

    systemctl start munin-node
    systemctl enable munin-node
}

# =========================================
# main
# =========================================

[ "$(whoami)" == "root" ] || abort "This script must be ran by root."

IS_CL=$(cat /etc/redhat-release 2>/dev/null | grep "CentOS Linux release 8")
IS_AL=$(cat /etc/system-release 2>/dev/null | grep "Amazon Linux release 2")

[ -z "${IS_CL}" -a -z "${IS_AL}" ] && abort "This script is only available on CentOS 8 or Amazon Linux 2."

if [ -n "${IS_CL}" ]; then
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
    systemctl stop firewalld
    systemctl disable firewalld
fi

run_packages
run_ssh
run_date
run_go
run_user
run_dotfiles
run_node
run_tmux
run_munin

