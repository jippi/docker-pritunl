# Pritunl as a Docker container

## Images

All images are published to the following registries

* [GitHub container registry](https://github.com/jippi/docker-pritunl/pkgs/container/docker-pritunl)
* [Amazon Web Services registry](https://gallery.ecr.aws/i2s8u4z7/pritunl)
* [Docker Hub](https://hub.docker.com/r/jippi/pritunl/)

Image tags with the specifications and version information can be found in the table below


| **Tag**                   | **Version**                                                                 | **OS**                  | **MongoDB?**           | **Wireguard**             | **size**        |
|-------------------------- |---------------------------------------------------------------------------- |-----------------------  |:---------------------: |:------------------------: |---------------- |
| `latest`                  | [latest †](https://github.com/pritunl/pritunl/releases/latest)              | Ubuntu Bionic (18.04)   |        ✅ (4.4)         |            ✅             | ~390 MB         |
| `latest-minimal`          | [latest †](https://github.com/pritunl/pritunl/releases/latest)              | Ubuntu Bionic (18.04)   |           ❌            |            ✅             | ~190 MB         |
| `latest-focal`            | [latest †](https://github.com/pritunl/pritunl/releases/latest)              | Ubuntu Focal (20.04)    |        ✅ (5.x)         |            ✅             | ~390 MB         |
| `latest-focal-minimal`    | [latest †](https://github.com/pritunl/pritunl/releases/latest)              | Ubuntu Focal (20.04)    |           ❌            |            ✅             | ~190 MB         |
| `$version`                | `$version`                                                                  | Ubuntu Bionic (18.04)   |        ✅ (4.4)         |            ✅             | ~390 MB         |
| `$version-minimal`        | `$version`                                                                  | Ubuntu Bionic (18.04)   |           ❌            |            ✅             | ~190 MB         |
| `$version-focal`          | `$version`                                                                  | Ubuntu Focal (20.04)    |        ✅ (5.x)         |            ✅             | ~390 MB         |
| `$version-focal-minimal`  | `$version`                                                                  | Ubuntu Focal (20.04)    |           ❌            |            ✅             | ~190 MB         |

_† Automation checks for new Pritunl releases nightly (CEST, ~3am), so there might be a day or two latency for most recent release_

## Config (env)

- `PRITUNL_DONT_WRITE_CONFIG` if set, `/etc/pritunl.conf` will not be auto-written on container start.
- `PRITUNL_DEBUG` must be `true` or `false` - controls the `debug` config key.
- `PRITUNL_BIND_ADDR` must be a valid IP on the host - defaults to `0.0.0.0` - controls the `bind_addr` config key.
- `PRITUNL_MONGODB_URI` URI to mongodb instance, default is starting a local mongodb instance in the container and use that.

## Usage

Just build it or pull it from jippi/pritunl. Run it something like this:

```sh
docker run \
    -d \
    --privileged \
    -p 1194:1194/udp \
    -p 1194:1194/tcp \
    -p 80:80/tcp \
    -p 443:443/tcp \
    jippi/pritunl
```

If you have a mongodb somewhere you'd like to use for this rather than starting the built-in one you can
do so through the `PRITUNL_MONGODB_URI` env var like this:

```sh
docker run \
    -d \
    --privileged \
    -e PRITUNL_MONGODB_URI=mongodb://some-mongo-host:27017/pritunl \
    -p 1194:1194/udp \
    -p 1194:1194/tcp \
    -p 80:80/tcp \
    -p 443:443/tcp \
    jippi/pritunl
```

Example production usage:

```sh

mkdir -p /gluster/docker0/pritunl/{mongodb,pritunl}
touch gluster/docker0/pritunl/pritunl.conf

docker run \
    --name=pritunl \
    --detach \
    --privileged \
    --network=host \
    --restart=always \
    -v /gluster/docker0/pritunl/mongodb:/var/lib/mongodb \
    -v /gluster/docker0/pritunl/pritunl:/var/lib/pritunl \
    -v /gluster/docker0/pritunl/pritunl.conf:/etc/pritunl.conf \
    jippi/pritunl
```

Then you can login to your pritunl web ui at https://docker-host-address

Username: pritunl Password: pritunl

I would suggest using docker data volume for persistent storage of pritunl data, something like this:

```sh
## create the data volume
docker run \
    -v /var/lib/pritunl \
    --name=pritunl-data busybox

## use the data volume when starting pritunl
docker run \
    --name pritunl \
    --privileged \
    --volumes-from=pritunl-data \
    -e PRITUNL_MONGODB_URI=mongodb://some-mongo-host:27017/pritunl \
    -p 1194:1194/udp \
    -p 1194:1194/tcp \
    -p 80:80/tcp \
    -p 443:443/tcp \
    jippi/pritunl
```

Then you're on your own, but take a look at http://pritunl.com or https://github.com/pritunl/pritunl

Based on `johnae/pritunl`
