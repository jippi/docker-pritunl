#!/bin/bash

set -ex

. /etc/lsb-release

# command shortcuts
APT_INSTALL="apt-get install --no-install-recommends --no-install-suggests --yes"
WGET="wget --quiet"

pritunl_deb_file="/pritunl/cache/pritunl_${PRITUNL_VERSION}-0ubuntu1.${DISTRIB_CODENAME}_amd64.deb"
if [ -e "${pritunl_deb_file}" ] && dpkg-deb --info "${pritunl_deb_file}" >/dev/null; then
    echo "OK! pritunl deb file already exsist in ${pritunl_deb_file} and is valid"
else
    echo "Downloading pritunl deb file to ${pritunl_deb_file}"
    $WGET --output-document="${pritunl_deb_file}" "https://github.com/pritunl/pritunl/releases/download/${PRITUNL_VERSION}/pritunl_${PRITUNL_VERSION}-0ubuntu1.${DISTRIB_CODENAME}_amd64.deb"
fi

$APT_INSTALL "${pritunl_deb_file}"
$APT_INSTALL wireguard wireguard-tools

rm -rf \
    /tmp/* \
    /var/log/pritunl.log \
    /var/log/mongodb/mongod.log
