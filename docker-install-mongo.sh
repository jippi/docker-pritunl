#!/bin/bash

set -ex

. /etc/lsb-release

APT_INSTALL="apt-get install --no-install-recommends --no-install-suggests --yes"
APT_UPDATE="apt-get update --quiet"
WGET="wget --quiet"

# install mongo in the container
if [ "${MONGODB_VERSION}" != "no" ]; then
    MONGODB_VERSION=4.4
    MONGODB_INSTALL_VERSION="4.4.*"

    # use modern mongo for focal
    if [ "${DISTRIB_CODENAME}" == "focal" ]; then
        MONGODB_VERSION=5.0
        MONGODB_INSTALL_VERSION="*"
    fi

    # use modern mongo for jammy
    if [ "${DISTRIB_CODENAME}" == "jammy" ]; then
        MONGODB_VERSION=6.0
        MONGODB_INSTALL_VERSION="*"
    fi

    $WGET --output-document=- https://www.mongodb.org/static/pgp/server-${MONGODB_VERSION}.asc | apt-key add -
    echo "deb [arch=amd64,arm64] https://repo.mongodb.org/apt/ubuntu ${DISTRIB_CODENAME}/mongodb-org/${MONGODB_VERSION} multiverse" | tee /etc/apt/sources.list.d/mongodb-org-${MONGODB_VERSION}.list

    $APT_UPDATE
    $APT_INSTALL mongodb-org="${MONGODB_INSTALL_VERSION}"
fi
