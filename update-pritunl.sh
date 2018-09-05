set -ex

# find latest tag from github
tag=$(curl https://api.github.com/repos/pritunl/pritunl/tags | jq -r '.[0].name')

# ensure checkout directory exist
if [ ! -d "/tmp/docker-pritunl" ]; then
    git clone https://github.com/jippi/docker-pritunl.git /tmp/docker-pritunl
fi

# change work dir
cd /tmp/docker-pritunl/

# update repo
git pull

# build without mongo (default container)
docker build -t "jippi/pritunl:${tag}" --build-arg PRITUNL_VERSION="${tag}*" --build-arg MONGODB_VERSION=no .
docker push "jippi/pritunl:${tag}"

docker tag "jippi/pritunl:${tag}" "jippi/pritunl:latest"
docker push "jippi/pritunl:latest"

# build with mongo (special tag)
docker build -t "jippi/pritunl:${tag}-mongo" --build-arg PRITUNL_VERSION="${tag}*" .
docker push "jippi/pritunl:${tag}-mongo"

docker tag "jippi/pritunl:${tag}" "jippi/pritunl:latest-mongo"
docker push "jippi/pritunl:latest-mongo"
