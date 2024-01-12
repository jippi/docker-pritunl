#!/bin/bash

set -ex

. /etc/lsb-release

# Ensure we keep apt cache around in a Docker environment
rm -f /etc/apt/apt.conf.d/docker-clean
echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache

# command shortcuts
APT_UPDATE="apt-get update --quiet"
APT_INSTALL="apt-get install --no-install-recommends --no-install-suggests --yes"

# install basic packages needed
$APT_UPDATE
$APT_INSTALL wget gnupg ca-certificates

# setup pritunl apt repo
echo "deb http://repo.pritunl.com/stable/apt ${DISTRIB_CODENAME} main" >/etc/apt/sources.list.d/pritunl.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7AE645C0CF8E292A

# configure timezone to be UTC by default
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

$APT_UPDATE
