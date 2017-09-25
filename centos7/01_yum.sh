#!/bin/bash

. ./lib

echo "Running yum update"
yum -y update

echo "Installing dev tools"
yum -y groupinstall "Development Tools"

echo "Installing essential packages"
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
	yum-cron
