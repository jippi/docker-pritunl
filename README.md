# Pritunl as a Docker container

## Images

All images are published to the following registries

* [GitHub container registry](https://github.com/jippi/docker-pritunl/pkgs/container/docker-pritunl) as `ghcr.io/jippi/docker-pritunl`
* [Amazon Web Services registry](https://gallery.ecr.aws/i2s8u4z7/pritunl) as `public.ecr.aws/i2s8u4z7/pritunl`
* [Docker Hub](https://hub.docker.com/r/jippi/pritunl/) as `jippi/docker-pritunl`

Image tags with the specifications and version information can be found in the table below

| **Tag**                   | **Version**                                                                 | **OS (Ubuntu)**         | **MongoDB**            | **Wireguard**             | **Size**        |
|-------------------------- |---------------------------------------------------------------------------- |-----------------------  |:---------------------: |:------------------------: |---------------- |
| `latest`                  | [latest †](https://github.com/pritunl/pritunl/releases/latest)              | Bionic (18.04)          |        ✅ (4.4)         |            ✅             | ~390 MB         |
| `latest-minimal`          | [latest †](https://github.com/pritunl/pritunl/releases/latest)              | Bionic (18.04)          |           ❌            |            ✅             | ~190 MB         |
| `latest-focal`            | [latest †](https://github.com/pritunl/pritunl/releases/latest)              | Focal (20.04)           |        ✅ (5.x)         |            ✅             | ~390 MB         |
| `latest-focal-minimal`    | [latest †](https://github.com/pritunl/pritunl/releases/latest)              | Focal (20.04)           |           ❌            |            ✅             | ~190 MB         |
| `$version`                | `$version`                                                                  | Bionic (18.04)          |        ✅ (4.4)         |            ✅             | ~390 MB         |
| `$version-minimal`        | `$version`                                                                  | Bionic (18.04)          |           ❌            |            ✅             | ~190 MB         |
| `$version-focal`          | `$version`                                                                  | Focal (20.04)           |        ✅ (5.x)         |            ✅             | ~390 MB         |
| `$version-focal-minimal`  | `$version`                                                                  | Focal (20.04)           |           ❌            |            ✅             | ~190 MB         |

_† Automation checks for new Pritunl releases nightly (CEST, ~3am), so there might be a day or two latency for most recent release_

## Config

Configuration settings that can be used via `--env` / `-e` CLI flag in `docker run`.

* `PRITUNL_DONT_WRITE_CONFIG` if set, `/etc/pritunl.conf` will not be auto-written on container start. _Any_ value will stop modifying the configuration file.
* `PRITUNL_DEBUG` must be `true` or `false` - controls the `debug` config key.
* `PRITUNL_BIND_ADDR` must be a valid IP on the host - defaults to `0.0.0.0` - controls the `bind_addr` config key.
* `PRITUNL_MONGODB_URI` URI to mongodb instance, default is starting a local MongoDB instance inside the container. _Any_ value will stop this behavior.

## Usage

I would recommend using a Docker `volume` or `bind` mount for persistent data like shown below

```sh
base_dir=$(pwd)

mkdir -p $(base_dir)/data/pritunl $(base_dir)/data/mongodb
touch $(base_dir)/data/pritunl.conf

docker run \
    --name pritunl \
    --privileged \
    --network=host \
    --dns 127.0.0.1 \
    --restart=unless-stopped \
    --detach \
    --volume $(base_dir)/data/pritunl.conf:/etc/pritunl.conf \
    --volume $(base_dir)/data/pritunl:/var/lib/pritunl \
    --volume $(base_dir)/data/mongodb:/var/lib/mongodb \
    jippi/docker-pritunl
```

If you have MongoDB running somewhere else you'd like to use, you can do so through the `PRITUNL_MONGODB_URI` env var like this:

```sh
base_dir=$(pwd)

mkdir -p $(base_dir)/data/pritunl
touch $(base_dir)/data/pritunl.conf

docker run \
    --name pritunl \
    --privileged \
    --network=host \
    --dns 127.0.0.1 \
    --restart=unless-stopped \
    --detach \
    --volume $(base_dir)/data/pritunl.conf:/etc/pritunl.conf \
    --volume $(base_dir)/data/pritunl:/var/lib/pritunl \
    --env PRITUNL_MONGODB_URI=mongodb://some-mongo-host:27017/pritunl \
    jippi/docker-pritunl
```

If you don't want to use `network=host`, then replace the `--network=host` CLI flag with the following ports + any ports you need for your configured Pritunl servers.

```sh
    --publish 80:80 \
    --publish 443:443 \
    --publish 1194:1194 \
    --publish 1194:1194/udp \
```

## Further help and docs

For any help specific to Pritunl please have a look at http://pritunl.com and https://github.com/pritunl/pritunl
