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
    if [ ${OS} == "CL" ]; then
        yum -y groupinstall --with-optional "Development Tools"
    elif [ ${OS} == "AL" ]; then
        yum -y groupinstall "Development Tools"
    fi

    debug "Installing essential packages"
    yum -y install \
        rsync \
        socat \
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
        mariadb \
        mariadb-server \
        mariadb-devel

    debug "Installing python"
    if [ ${OS} == "CL" ]; then
        yum -y install python36
    elif [ ${OS} == "AL" ]; then
        yum -y install python3
    fi

    debug "Installing Docker / Podman"
    if [ ${OS} == "CL" ]; then
        yum -y install podman podman-docker
    elif [ ${OS} == "AL" ]; then
        yum -y install docker
    fi

    debug "Installing epel"
    if [ ${OS} == "CL" ]; then
        rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    elif [ ${OS} == "AL" ]; then
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
    if [ ${OS} == "CL" ]; then
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
        cd /usr/local/src
        curl -OL https://dl.google.com/go/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
        tar xzf go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
        mv go /usr/local/go
        ln -s /usr/local/go/bin/go* /usr/local/bin/
    fi

    mkdir ~/go 
}

# =========================================
# node
# =========================================

run_node(){
    debug "Install Node"
    NODE_VERSION="14.5.3"

    uname -a | grep -q x86_64 && NODE_ARCH="x64"
    uname -a | grep -q aarch64 && NODE_ARCH="arm64"

    if [ -n "${NODE_ARCH}" ]; then
        cd /usr/local/src
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
    ./configure --prefix=/usr/local/tmux && make && make install
    ln -s /usr/local/tmux/bin/tmux /usr/local/bin/
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
# dotfiles
# =========================================

run_dotfiles(){
    debug "Installing ghq"
    /usr/local/bin/go get github.com/x-motemen/ghq

    debug "Install dotfiles"
    ~/go/bin/ghq get https://github.com/lowply/dotfiles.git
    ~/ghq/github.com/lowply/dotfiles/install do

    echo '0 7 * * * ${HOME}/ghq/github.com/lowply/dotfiles/bin/pull_dotfiles.sh >/dev/null' >> /var/spool/cron/root
    chmod 600 /var/spool/cron/root
}

# =========================================
# main
# =========================================

[ "$(whoami)" == "root" ] || abort "This script must be ran by root."

if [[ "$(cat /etc/system-release)" =~ "CentOS Linux release 8" ]]; then
    OS="CL"
elif [[ "$(cat /etc/system-release)" =~ "Amazon Linux release 2" ]]; then
    OS="AL"
fi

[ -z "${OS}" ] && abort "This script is only available on CentOS 8.x or Amazon Linux 2."

if [ $OS == "CL" ]; then
    if [ $(getenforce) != "Disabled" ]; then
        setenforce 0
        sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
    fi
    systemctl stop firewalld
    systemctl disable firewalld
fi

run_packages
run_ssh
run_date
run_go
run_node
run_tmux
run_user
run_dotfiles
