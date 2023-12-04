#!/bin/bash

set -ex

. /etc/lsb-release

# command shortcuts
APT_UPDATE="apt-get update --quiet"
APT_INSTALL="apt-get install --no-install-recommends --no-install-suggests --yes"
WGET="wget --quiet"

# keep APT packages so buildkit can cache them instead
rm -fv /etc/apt/apt.conf.d/docker-clean

# install basic packages needed
$APT_UPDATE
$APT_INSTALL wget gnupg ca-certificates

# setup pritunl apt repo
echo "deb http://repo.pritunl.com/stable/apt ${DISTRIB_CODENAME} main" > /etc/apt/sources.list.d/pritunl.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7AE645C0CF8E292A

# configure timezone to be UTC by default
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# install mongo in the container
if [ "${MONGODB_VERSION}" != "no" ]
then
    MONGODB_VERSION=4.4
    MONGODB_INSTALL_VERSION="4.4.*"

    # use modern mongo for focal
    if [ "${DISTRIB_CODENAME}" == "focal" ]
    then
        MONGODB_VERSION=5.0
        MONGODB_INSTALL_VERSION="*"
    fi

    # use modern mongo for jammy
    if [ "${DISTRIB_CODENAME}" == "jammy" ]
    then
        MONGODB_VERSION=6.0
        MONGODB_INSTALL_VERSION="*"
    fi

    $WGET --output-document=- https://www.mongodb.org/static/pgp/server-${MONGODB_VERSION}.asc | apt-key add -
    echo "deb [arch=amd64,arm64] https://repo.mongodb.org/apt/ubuntu ${DISTRIB_CODENAME}/mongodb-org/${MONGODB_VERSION} multiverse" | tee /etc/apt/sources.list.d/mongodb-org-${MONGODB_VERSION}.list

    $APT_UPDATE
    $APT_INSTALL mongodb-org="${MONGODB_INSTALL_VERSION}"
else
    $APT_UPDATE
fi

pritunl_deb_file="/pritunl/cache/pritunl_${PRITUNL_VERSION}-0ubuntu1.${DISTRIB_CODENAME}_amd64.deb"
if [ ! -e "${pritunl_deb_file}" ]
then
    echo "Downloading pritunl deb file to ${pritunl_deb_file}"
    $WGET --output-document="${pritunl_deb_file}" "https://github.com/pritunl/pritunl/releases/download/${PRITUNL_VERSION}/pritunl_${PRITUNL_VERSION}-0ubuntu1.${DISTRIB_CODENAME}_amd64.deb"
else
    echo "OK! pritunl deb file already exsist in ${pritunl_deb_file}"
fi

$APT_INSTALL $pritunl_deb_file
$APT_INSTALL wireguard wireguard-tools

rm -rf \
    /tmp/* \
    /var/log/pritunl.log \
    /var/log/mongodb/mongod.log
