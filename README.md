## Pritunl as a Docker container

Just build it or pull it from jippi/pritunl. Run it something like this:

```
docker run -d --privileged -p 1194:1194/udp -p 1194:1194/tcp -p 9700:9700/tcp jippi/pritunl
```

If you have a mongodb somewhere you'd like to use for this rather than starting the built-in one you can
do so through the MONGODB_URI env var like this:

```
docker run -d --privileged -e MONGODB_URI=mongodb://some-mongo-host:27017/pritunl -p 1194:1194/udp -p 1194:1194/tcp -p 9700:9700/tcp jippi/pritunl
```

Then you can login to your pritunl web ui at https://docker-host-address:9700
Username: pritunl Password: pritunl

I would suggest using docker data volume for persistent storage of pritunl data, something like this:

```shell
## create the data volume
docker run -v /var/lib/pritunl --name=pritunl-data busybox
## use the data volume when starting pritunl
docker run --name pritunl --privileged --volumes-from=pritunl-data -e MONGODB_URI=mongodb://some-mongo-host:27017/pritunl -p 1194:1194/udp -p 1194:1194/tcp -p 9700:9700/tcp -e SERVICE_NAME=%H -e SERVICE_1194_ID=pritunl-vpn -e SERVICE_9700_ID=pritunl-web jippi/pritunl
```

Then you're on your own, but take a look at http://pritunl.com or https://github.com/pritunl/pritunl

Based on `johnae/pritunl`
