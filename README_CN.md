<p align="left">
    <a href="README.md">English</a>&nbsp ｜&nbsp 中文
</p>
<br><br>

# 在 Docker 中运行 Pritunl

> Pritunl是与专有商业VPN产品（如Aviatrix和Pulse Secure）相比最优秀的开源替代方案。通过Pritunl，您可以构建支持数千个并发用户的庞大云VPN网络，并且无需为每个用户支付额外费用，从而更好地掌控您的VPN服务器。

## docker镜像

所有的Docker镜像都在下面表格中：

* 🥇 [GitHub](https://github.com/jippi/docker-pritunl/pkgs/container/docker-pritunl) as `ghcr.io/jippi/docker-pritunl` ⬅️ **推荐**
* 🥈 [AWS](https://gallery.ecr.aws/jippi/pritunl) as `public.ecr.aws/jippi/pritunl` ⬅️ 绝佳的替代选择
* ⚠️ [Docker Hub](https://hub.docker.com/r/jippi/pritunl/) as `jippi/docker-pritunl` ⬅️ 只能使用 `:latest` 作为 [tags 才可能拉取到镜像](https://www.docker.com/blog/scaling-dockers-business-to-serve-millions-more-developers-storage/)


不同的规格和版本的镜像标签（tags）可以在下面的表格中找到

| **Tag**                   | **Version**                                                     | **系统 (Ubuntu)**         | **MongoDB**            | **Wireguard**             |
|-------------------------- |---------------------------------------------------------------- |-----------------------  |:---------------------: |:------------------------: |
| `latest`                  | [latest †](https://github.com/pritunl/pritunl/releases/latest)  | Jammy (22.04)           |        ✅ (6.x)         |            ✅             |
| `latest-minimal`          | [latest †](https://github.com/pritunl/pritunl/releases/latest)  | Jammy (22.04)           |           ❌            |            ✅             |
| `latest-focal`            | [latest †](https://github.com/pritunl/pritunl/releases/latest)  | Focal (20.04)           |        ✅ (5.x)         |            ✅             |
| `latest-focal-minimal`    | [latest †](https://github.com/pritunl/pritunl/releases/latest)  | Focal (20.04)           |           ❌            |            ✅             |
| `$version`                | `$version`                                                      | Jammy (22.04)           |        ✅ (6.x)         |            ✅             |
| `$version-minimal`        | `$version`                                                      | Jammy (22.04)           |           ❌            |            ✅             |
| `$version-focal`          | `$version`                                                      | Focal (20.04)           |        ✅ (5.x)         |            ✅             |
| `$version-focal-minimal`  | `$version`                                                      | Focal (20.04)           |           ❌            |            ✅             |

_† 每晚（欧洲中部夏令时，约凌晨3点），自动化程序会检查Pritunl是否有新版本发布，因此最新版本的发布可能会有一两天的延迟。_

## 获取默认的用户名和密码

运行下面的命令获取默认的登录用户名和密码：

```sh
docker exec -it [container_name] pritunl default-password
```

Ex:

```sh
docker exec -it pritunl pritunl default-password
```

## 配置

可以通过在`docker run`后面添加`--env` / `-e` 来使用配置。



* `PRITUNL_DONT_WRITE_CONFIG` 如果设置, `/etc/pritunl.conf` 容器启动时将不会自动被重写. _Any_ value will stop modifying the configuration file.
* `PRITUNL_DEBUG` 只能为 `true` 或者 `false` - 控制 `debug`配置项，在需要调试时使用.
* `PRITUNL_BIND_ADDR` 只能是服务器的某个ip - defaults to `0.0.0.0` - 控制 `bind_addr` 配置项，用于指定绑定要监听的ip.
* `PRITUNL_MONGODB_URI` MongoDB 实例的 URI，如果未指定，默认是在容器内部启动一个本地 MongoDB 实例。 _Any_ value will stop this behavior.

## 使用内置的 MongoDB

我建议使用Docker的`volume`或`bind`挂载来处理持久化数据，如下面的示例所示：

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

## 不使用内容的 MongoDB

我建议使用Docker的`volume`或`bind`挂载来处理持久化数据，如下面的示例所示：

如果您想要使用其他地方运行的MongoDB，您可以通过设置`PRITUNL_MONGODB_URI`环境变量来实现，就像下面的示例中所展示的那样。

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

在当前目录(`$(pwd)`)将下面内容添加到`docker-compose.yaml`文件中，然后执行`docker-compose up -d`



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

如果您不想使用`network=host`，请将`--network=host`命令行选项 替换为以下端口加上您配置的Pritunl服务器所需的任何端口。

```sh
    --publish 80:80 \
    --publish 443:443 \
    --publish 1194:1194 \
    --publish 1194:1194/udp \
```

如果在使用的是 `docker-compose`，请将`network_mode: host` 替换为以下端口加上您配置的Pritunl服务器所需的任何端口。


```yaml
         ports:
            - '80:80'
            - '443:443'
            - '1194:1194'
            - '1194:1194/udp'
```

## 升级 MongoDB

**重要**: 停止你的 `pritunl` docker 容器 (`docker stop pritunl`) 在执行下面步骤前

升级的模式基本相同，唯一的变化是MongoDB的版本号，文档可以在这里找到：

* [从 3.2 升级到 3.6](https://www.mongodb.com/docs/manual/release-notes/3.6-upgrade-standalone/#prerequisites)
* [从 from 3.6 升级到 4.0](https://www.mongodb.com/docs/manual/release-notes/4.0-upgrade-standalone/#prerequisites)
* [从 from 4.0 升级到 4.2](https://www.mongodb.com/docs/manual/release-notes/4.2-upgrade-standalone/#prerequisites)
* [从 from 4.2 升级到 4.4](https://www.mongodb.com/docs/manual/release-notes/4.4-upgrade-standalone/#prerequisites) <- 不能升级了，如果你使用的是 `Bionic (18.04)`
* [从 from 4.4 升级到 5.0](https://www.mongodb.com/docs/manual/release-notes/5.0-upgrade-standalone/#prerequisites) <- 不能升级了，如果你使用的是 `Focal (20.04)`

### 自动升级脚本

我制作了一个小脚本叫做 [mongo-upgrade.sh](https://github.com/jippi/docker-pritunl/blob/master/mongo-upgrade.sh) ，您可以下载到您的服务器并运行它。它会尽力引导您完成升级所需的步骤。

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

### 手动升级

假设你的版本是 `3.2`, 要升级的版不能是 `3.6` 你需要设置环境变量 `$NEXT_VERSION_TO_UPGRADE_TO=3.6` 并且运行下面命令。

您可以在上述脚本中查看您需要运行的版本列表。

从3.2版本升级到4.4版本的示例路径意味着需要按照以下值的每个`NEXT_VERSION_TO_UPGRADE_TO`运行脚本一次：

* `NEXT_VERSION_TO_UPGRADE_TO=3.2`
* `NEXT_VERSION_TO_UPGRADE_TO=3.6`
* `NEXT_VERSION_TO_UPGRADE_TO=4.0`
* `NEXT_VERSION_TO_UPGRADE_TO=4.2`
* `NEXT_VERSION_TO_UPGRADE_TO=4.4`

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

## 进一步的帮助和文档请参考以下内容：

如果需要有关Pritunl的特定帮助，请查看以下网址：<http://pritunl.com> 和 <https://github.com/pritunl/pritunl>
