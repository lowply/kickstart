#!/bin/bash

USERNAME="lowply"
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
    yum -y groupinstall "Development Tools"

    debug "Installing essential packages"
    yum -y install \
        gcc \
        cmake \
        autoconf \
        patch \
        perl-devel \
        curl-devel \
        expat-devel \
        readline-devel \
        sqlite-devel \
        bzip2-devel \
        zlib-devel \
        man \
        bash-completion \
        openssl \
        openssl-devel \
        asciidoc \
        xmlto \
        pwgen \
        bind-utils \
        dstat \
        net-tools \
        httpd \
        yum-cron \
        python3 \
        vim \
        docker \
        mariadb \
        mariadb-server \
        git

    debug "Installing epel"
    sudo amazon-linux-extras install epel

    ln -s /usr/share/git-core/contrib/diff-highlight /usr/local/bin
}

# =========================================
# SSH port
# =========================================

run_ssh(){
    debug "Change SSH port"
    sed -i 's/#Port 22/Port 1417/' /etc/ssh/sshd_config
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
    GO_VERSION="1.14.1"

    uname -a | grep -q x86_64 && GO_ARCH="amd64"
    uname -a | grep -q aarch64 && GO_ARCH="arm64"

    if [ -n "${GO_ARCH}" ]; then
        curl -OL https://dl.google.com/go/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
        tar xzf go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
        mv go /usr/local/go
        ln -s /usr/local/go/bin/go* /usr/local/bin/
    fi
}

# =========================================
# User
# =========================================

run_user(){
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

    debug "Installing ghq"
    su ${USERNAME} -lc "mkdir ~/go" 
    su ${USERNAME} -lc "go get github.com/x-motemen/ghq"

    debug "Install dotfiles"
    su ${USERNAME} -lc "~/go/bin/ghq get https://github.com/lowply/dotfiles.git"
    su ${USERNAME} -lc "~/ghq/github.com/lowply/dotfiles/install do"
}

# =========================================
# crontabs
# =========================================

run_crontab(){
    echo "0 7 * * * /home/${USERNAME}/.ghq/github.com/lowply/dotfiles/bin/pull_dotfiles.sh >/dev/null" > /var/spool/cron/${USERNAME}
    chown ${USERNAME}:wheel /var/spool/cron/${USERNAME}
    chmod 600 /var/spool/cron/${USERNAME}
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
    TMUX_VERSION="3.0a"

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
    yum -y install munin --enablerepo=epel

    systemctl start munin-node
    systemctl enable munin-node
}

run_packages
run_ssh
run_date
run_go
run_user
run_crontab
run_node
run_tmux
run_munin

# TODO
# Nagios, docker-compose
