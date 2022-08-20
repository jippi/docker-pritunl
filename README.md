# Pritunl as a Docker container

> Pritunl is the best open source alternative to proprietary commercial vpn products such as Aviatrix and Pulse Secure. Create larger cloud vpn networks supporting thousands of concurrent users and get more control over your vpn server without any per-user pricing.

## Images

All images are published to the following registries

* 🥇 [GitHub](https://github.com/jippi/docker-pritunl/pkgs/container/docker-pritunl) as `ghcr.io/jippi/docker-pritunl` ⬅️ **Recommended**
* 🥈 [AWS](https://gallery.ecr.aws/i2s8u4z7/pritunl) as `public.ecr.aws/i2s8u4z7/pritunl` ⬅️ Great alternative
* ⚠️ [Docker Hub](https://hub.docker.com/r/jippi/pritunl/) as `jippi/docker-pritunl` ⬅️ Only use `:latest` as [tags might disappear](https://www.docker.com/blog/scaling-dockers-business-to-serve-millions-more-developers-storage/)

Image tags with software specifications and version information can be found in the table below

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

## Default user and password

* User: `pritunl`
* Password: `pritunl`

## Config

Configuration settings that can be used via `--env` / `-e` CLI flag in `docker run`.

* `PRITUNL_DONT_WRITE_CONFIG` if set, `/etc/pritunl.conf` will not be auto-written on container start. _Any_ value will stop modifying the configuration file.
* `PRITUNL_DEBUG` must be `true` or `false` - controls the `debug` config key.
* `PRITUNL_BIND_ADDR` must be a valid IP on the host - defaults to `0.0.0.0` - controls the `bind_addr` config key.
* `PRITUNL_MONGODB_URI` URI to mongodb instance, default is starting a local MongoDB instance inside the container. _Any_ value will stop this behavior.

## Usage with embedded MongoDB

I would recommend using a Docker `volume` or `bind` mount for persistent data like shown in the examples below

### docker run (with mongo)

```sh
data_dir=$(pwd)/data

mkdir -p $(data_dir)/pritunl $(data_dir)/mongodb
touch $(data_dir)/pritunl.conf

docker run \
    --name pritunl \
    --privileged \
    --network=host \
    --dns 127.0.0.1 \
    --restart=unless-stopped \
    --detach \
    --volume $(data_dir)/pritunl.conf:/etc/pritunl.conf \
    --volume $(data_dir)/pritunl:/var/lib/pritunl \
    --volume $(data_dir)/mongodb:/var/lib/mongodb \
    ghcr.io/jippi/docker-pritunl
```

### docker-compose (with mongo)

```sh
data_dir=$(pwd)/data

mkdir -p $(data_dir)/pritunl $(data_dir)/mongodb
touch $(data_dir)/pritunl.conf
```

and then the following `docker-compose.yaml` file in `$(pwd)` followed by `docker-compose up -d`

```yaml
version: '3.3'
services:
    pritunl:
        container_name: pritunl
        image: ghcr.io/jippi/docker-pritunl
        restart: unless-stopped
        privileged: true
        network_mode: host
        dns:
            - 127.0.0.1
        volumes:
            - './data/pritunl.conf:/etc/pritunl.conf'
            - './data/pritunl:/var/lib/pritunl'
            - './data/mongodb:/var/lib/mongodb'
```

## Usage without embedded MongoDB

I would recommend using a Docker `volume` or `bind` mount for persistent data like shown in the examples below

If you have MongoDB running somewhere else you'd like to use, you can do so through the `PRITUNL_MONGODB_URI` env var like shown below

### docker run (without mongo)

```sh
data_dir=$(pwd)/data

mkdir -p $(data_dir)/pritunl
touch $(data_dir)/pritunl.conf

docker run \
    --name pritunl \
    --privileged \
    --network=host \
    --dns 127.0.0.1 \
    --restart=unless-stopped \
    --detach \
    --volume $(data_dir)/pritunl.conf:/etc/pritunl.conf \
    --volume $(data_dir)/pritunl:/var/lib/pritunl \
    --env PRITUNL_MONGODB_URI=mongodb://some-mongo-host:27017/pritunl \
    ghcr.io/jippi/docker-pritunl
```

### docker-compose (without mongo)

```sh
data_dir=$(pwd)/data

mkdir -p $(data_dir)/pritunl
touch $(data_dir)/pritunl.conf
```

and then the following `docker-compose.yaml` file in `$(pwd)` followed by `docker-compose up -d`

```yaml
version: '3.3'
services:
    pritunl:
        container_name: pritunl
        image: ghcr.io/jippi/docker-pritunl
        restart: unless-stopped
        privileged: true
        network_mode: host
        dns:
            - 127.0.0.1
        environment:
            - PRITUNL_MONGODB_URI=mongodb://some-mongo-host:27017/pritunl
        volumes:
            - './data/pritunl.conf:/etc/pritunl.conf'
            - './data/pritunl:/var/lib/pritunl'
```

## Network mode

If you don't want to use `network=host`, then replace the `--network=host` CLI flag with the following ports + any ports you need for your configured Pritunl servers.

```sh
    --publish 80:80 \
    --publish 443:443 \
    --publish 1194:1194 \
    --publish 1194:1194/udp \
```

or for `docker-compose`

```yaml
         ports:
            - '80:80'
            - '443:443'
            - '1194:1194'
            - '1194:1194/udp'
```

## Upgrading MongoDB

**IMPORTANT**: Stop your `pritunl` docker container (`docker stop pritunl`) before doing these steps

The pattern for upgrading are basically the same, with the only variance being the MongoDB version number, the docs can be found here:

* [Upgrade from 3.2 to 3.6](https://www.mongodb.com/docs/manual/release-notes/3.6-upgrade-standalone/#prerequisites)
* [Upgrade from 3.6 to 4.0](https://www.mongodb.com/docs/manual/release-notes/4.0-upgrade-standalone/#prerequisites)
* [Upgrade from 4.0 to 4.2](https://www.mongodb.com/docs/manual/release-notes/4.2-upgrade-standalone/#prerequisites)
* [Upgrade from 4.2 to 4.4](https://www.mongodb.com/docs/manual/release-notes/4.4-upgrade-standalone/#prerequisites) <- stop here if you use `Bionic (18.04)`
* [Upgrade from 4.4 to 5.0](https://www.mongodb.com/docs/manual/release-notes/5.0-upgrade-standalone/#prerequisites) <- stop here if you use `Focal (20.04)`

### Automated script

I've made a small script called [mongo-upgrade.sh](https://github.com/jippi/docker-pritunl/blob/master/mongo-upgrade.sh) that you can download to your server and run. It will make an best-effort to guide you through the steps needed to upgrade.

```sh
# fetch the script
wget -O mongo-upgrade.sh https://raw.githubusercontent.com/jippi/docker-pritunl/master/mongo-upgrade.sh
# make it executable
chmod +x mongo-upgrade.sh
# edit settings
vi mongo-upgrade.sh
# run
./mongo-upgrade.sh
```

### Manual upgrade

Assuming you are coming from `3.2`, your next version is `3.6` so you need to set `$NEXT_VERSION_TO_UPGRADE_TO=3.6` and run these commands. You can see the versions you would need to run the script for above.

Path from 3.2 to 4.4 would be the following:

* `NEXT_VERSION_TO_UPGRADE_TO=3.2`
* `NEXT_VERSION_TO_UPGRADE_TO=3.6`
* `NEXT_VERSION_TO_UPGRADE_TO=4.0`
* `NEXT_VERSION_TO_UPGRADE_TO=4.2`
* `NEXT_VERSION_TO_UPGRADE_TO=4.4`

Run this script for each version above

```sh
NEXT_VERSION_TO_UPGRADE_TO=
MONGODB_DATA_PATH=$PATH_TO_YOUR_MONGODB_DB_FOLDER # must point to the directory where files like `mongod.lock` and `journal/` are on disk.

# Start MongoDB server
docker run -d --name temp-mongo-server --rm -it -v ${MONGODB_DATA_PATH}:/data/db mongo:${NEXT_VERSION_TO_UPGRADE_TO}

# Wait for server to start
sleep 5

# change setFeatureCompatibilityVersion to current version
docker exec temp-mongo-server mongo admin --quiet --eval "db.adminCommand( { setFeatureCompatibilityVersion: \"${NEXT_VERSION_TO_UPGRADE_TO}\" } );"

# stop the server gracefully
docker exec -it temp-mongo-server mongo admin --quiet --eval "db.shutdownServer()"

# Wait for the server to stop
sleep 5

# make sure container is stopped
docker stop temp-mongo-server

# remove container
docker rm -f temp-mongo-server

# repair / upgrade data
docker run --rm --volume ${MONGODB_DATA_PATH}:/data/db mongo:${NEXT_VERSION_TO_UPGRADE_TO} --repair
```

## Further help and docs

For any help specific to Pritunl please have a look at http://pritunl.com and https://github.com/pritunl/pritunl
