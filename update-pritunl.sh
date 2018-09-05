set -e
set -o pipefail

DOCKER_ARGS="--squash"
DEBUG=${DEBUG:0}

if [ "${DEBUG}" != "1" ]; then
    DOCKER_ARGS="$DOCKER_ARGS --quiet"
fi

if [ "${DEBUG}" == "1" ]; then
    set -x
fi

# ensure checkout directory exist
if [ ! -d "/tmp/docker-pritunl" ]; then
    git clone https://github.com/jippi/docker-pritunl.git /tmp/docker-pritunl
fi

# change work dir
# cd /tmp/docker-pritunl/

# update repo
# git pull

# docker tags
docker_tags=$(curl -s https://hub.docker.com/v2/repositories/jippi/pritunl/tags/ | jq -r '.results[].name')
docker_tags=""

function has_tag() {
    check=$(echo "${docker_tags}" | grep "^$1$")
    if [ "${check}" == "" ]; then
        return 1
    else
        return 0
    fi
}

# find latest tag from github
github_tags=$(curl -s https://api.github.com/repos/pritunl/pritunl/tags | jq -r '.[].name')
first=1
for tag in $github_tags; do
    echo "[${tag}] Processing"

    # build with mongo (default container)
    if ! has_tag "${tag}"; then
        echo "[${tag}] Building"
        docker build $DOCKER_ARGS -t "jippi/pritunl:${tag}" --build-arg PRITUNL_VERSION="${tag}" .

        echo "[${tag}] Pushing"
        docker push "jippi/pritunl:${tag}"

        if [ $first -eq 1 ]; then
            echo "[${tag}] Tagging as latest"
            docker tag "jippi/pritunl:${tag}" "jippi/pritunl:latest"

            echo "[${tag}] Pushing as latest"
            docker push "jippi/pritunl:latest"
        fi

        echo "[${tag}] Done"
    else
        echo "[${tag}] Already build"
    fi

    # build without mongo (special tag)
    if ! has_tag "${tag}-minimal"; then
        echo "[${tag}-minimal] Building"
        docker build $DOCKER_ARGS -t "jippi/pritunl:${tag}-minimal" --build-arg PRITUNL_VERSION="${tag}" --build-arg MONGODB_VERSION=no .

        echo "[${tag}-minimal] Pushing"
        docker push "jippi/pritunl:${tag}-minimal"

        if [ $first -eq 1 ]; then
            echo "[${tag}-minimal] Tagging as latest-minimal"
            docker tag "jippi/pritunl:${tag}-minimal" "jippi/pritunl:latest-minimal"

            echo "[${tag}-minimal] Pushing as latest-minimal"
            docker push "jippi/pritunl:latest-minimal"
        fi

        echo "[${tag}-minimal] Done"
    else
        echo "[${tag}-minimal] Already build"
    fi

    first=0
done
