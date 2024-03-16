#!/bin/bash

set -o errexit -o nounset -o pipefail

. /etc/lsb-release

pritunl_deb_file="/pritunl/cache/pritunl_${PRITUNL_VERSION:?}-0ubuntu1.${DISTRIB_CODENAME}_amd64.deb"
if [[ -e "${pritunl_deb_file}" ]] && dpkg-deb --info "${pritunl_deb_file}" >/dev/null; then
    echo "OK! pritunl deb file already exsist in ${pritunl_deb_file} and is valid"
else
    echo "Downloading pritunl deb file to ${pritunl_deb_file}"
    wget --quiet --output-document="${pritunl_deb_file}" "https://github.com/pritunl/pritunl/releases/download/${PRITUNL_VERSION:?}/pritunl_${PRITUNL_VERSION:?}-0ubuntu1.${DISTRIB_CODENAME:?}_amd64.deb"
fi

apt-get update --quiet
apt-get install --no-install-recommends --no-install-suggests --yes "${pritunl_deb_file}" wireguard wireguard-tools

rm -rf \
    /tmp/* \
    /var/log/pritunl.log \
    /var/log/mongodb/mongod.log
