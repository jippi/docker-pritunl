set -ex

apt-get update -q
apt-get install -y gnupg wget

if [ "${MONGODB_VERSION}" != "no" ]; then
    wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
fi

echo 'deb http://repo.pritunl.com/stable/apt bionic main' > /etc/apt/sources.list.d/pritunl.list
echo "deb http://build.openvpn.net/debian/openvpn/stable bionic main" > /etc/apt/sources.list.d/openvpn-aptrepo.list

apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 8E6DA8B4E158C569

apt-get update -q
apt-get install -y locales iptables wget
locale-gen en_US en_US.UTF-8
dpkg-reconfigure locales
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
apt-get upgrade -y -q
apt-get dist-upgrade -y -q

wget --quiet https://github.com/pritunl/pritunl/releases/download/${PRITUNL_VERSION}/pritunl_${PRITUNL_VERSION}-0ubuntu1.bionic_amd64.deb
dpkg -i pritunl_${PRITUNL_VERSION}-0ubuntu1.bionic_amd64.deb || apt-get -f -y install
rm pritunl_${PRITUNL_VERSION}-0ubuntu1.bionic_amd64.deb

if [ "${MONGODB_VERSION}" != "no" ]; then
    apt-get -y install mongodb-org=${MONGODB_VERSION};
fi

apt-get --purge autoremove -y wget
apt-get clean
apt-get -y -q autoclean
apt-get -y -q autoremove
rm -rf /tmp/*
