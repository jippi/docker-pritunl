#!/bin/bash

set -o errexit -o nounset -o pipefail

. /etc/lsb-release

# Ensure we keep apt cache around in a Docker environment
rm -f /etc/apt/apt.conf.d/docker-clean
echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache

# install basic packages needed
apt-get update --quiet
apt-get install --no-install-recommends --no-install-suggests --yes wget gnupg ca-certificates

# setup pritunl apt repo
wget --quiet --output-document=- "https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc" \
	| gpg --dearmor --yes --output /usr/share/keyrings/pritunl-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/pritunl-archive-keyring.gpg] http://repo.pritunl.com/stable/apt ${DISTRIB_CODENAME} main" \
	>/etc/apt/sources.list.d/pritunl.list

# configure timezone to be UTC by default
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

apt-get update --quiet
