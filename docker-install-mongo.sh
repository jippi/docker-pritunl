#!/bin/bash

set -o errexit -o nounset -o pipefail

if [[ "${MONGODB_VERSION}" == "no" ]]; then
    exit 0
fi

. /etc/lsb-release

case "${DISTRIB_CODENAME}" in
focal)
    MONGODB_VERSION=5.0
    MONGODB_INSTALL_VERSION="*"
    ;;

*)
    MONGODB_VERSION=6.0
    MONGODB_INSTALL_VERSION="*"
    ;;
esac

# grab signing key
wget --quiet --output-document=- "https://www.mongodb.org/static/pgp/server-${MONGODB_VERSION:?}.asc" \
    | gpg --dearmor --yes --output "/usr/share/keyrings/mongodb-server-${MONGODB_VERSION}.gpg"

# setup apt repo
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-${MONGODB_VERSION}.gpg] https://repo.mongodb.org/apt/ubuntu ${DISTRIB_CODENAME}/mongodb-org/${MONGODB_VERSION} multiverse" \
    >"/etc/apt/sources.list.d/mongodb-org-${MONGODB_VERSION}.list"

# install mongodb
apt-get update --quiet
apt-get install --no-install-recommends --no-install-suggests --yes mongodb-org="${MONGODB_INSTALL_VERSION}"
