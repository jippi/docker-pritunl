set -ex

if [ "${MONGODB_VERSION}" != "no" ]; then
    echo 'deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse' > /etc/apt/sources.list.d/mongodb-org-3.2.list
    apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 42F3E95A2C4F08279C4960ADD68FA50FEA312927
fi

echo 'deb http://repo.pritunl.com/stable/apt xenial main' > /etc/apt/sources.list.d/pritunl.list
echo "deb http://build.openvpn.net/debian/openvpn/stable xenial main" > /etc/apt/sources.list.d/openvpn-aptrepo.list

apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 8E6DA8B4E158C569

apt-get update -q
apt-get install -y locales iptables wget
locale-gen en_US en_US.UTF-8
dpkg-reconfigure locales
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
apt-get upgrade -y -q
apt-get dist-upgrade -y -q

wget --quiet https://github.com/pritunl/pritunl/releases/download/${PRITUNL_VERSION}/pritunl_${PRITUNL_VERSION}-0ubuntu1.xenial_amd64.deb
dpkg -i pritunl_${PRITUNL_VERSION}-0ubuntu1.xenial_amd64.deb || apt-get -f -y install
rm pritunl_${PRITUNL_VERSION}-0ubuntu1.xenial_amd64.deb

if [ "${MONGODB_VERSION}" != "no" ]; then
    apt-get -y install mongodb-org=${MONGODB_VERSION};
fi

apt-get --purge autoremove -y wget
apt-get clean
apt-get -y -q autoclean
apt-get -y -q autoremove
rm -rf /tmp/*
