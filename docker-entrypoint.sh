#!/bin/bash -ex

: ${PRITUNL_DEBUG=false}
: ${PRITUNL_BIND_ADDR=0.0.0.0}
: ${PRITUNL_TMP_PATH=$(mktemp -d -t pritunlXXXX)}
: ${PRITUNL_MONGODB_URI=mongodb://localhost:27017/pritunl}

# in the case of user a local mongodb
mkdir -p /data/db

if [[ "$PRITUNL_MONGODB_URI" =~ .*localhost.* ]]; then
  echo "localhost for mongodb, assume running mongod within non-privileged container"
  exec mongod &

  # give mongodb a bit of time to init
  sleep 3
fi

cat << EOF > /etc/pritunl.conf
{
  "mongodb_uri": "$PRITUNL_MONGODB_URI",
  "log_path": "/var/log/pritunl.log",
  "static_cache": true,
  "temp_path": "$PRITUNL_TMP_PATH",
  "debug": $PRITUNL_DEBUG,
  "bind_addr": "$PRITUNL_BIND_ADDR",
  "www_path": "/usr/share/pritunl/www",
  "local_address_interface": "auto",
  "port": 443
}
EOF

exec pritunl logs --tail &

echo "> $@" && exec "$@"
