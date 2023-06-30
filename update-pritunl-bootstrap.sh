set -o errexit -o nounset -o pipefail

if [ "${MAIN_LOADED}" != "1" ]; then
    echo "Should not be loaded or run directly, please use [update-pritunl.sh]"
    exit 1
fi

BLUE='\033[1;34m'
GREEN='\033[1;32m'
NO_COLOR='\033[0m'
RED='\033[0;31m'
YELLOW='\033[0;33m'

function print() {
    echo $OUTPUT_PREFIX $@
}

function debug() {
    if [[ "${DEBUG}" -gt "0" ]]
    then
        echo $OUTPUT_PREFIX $@
    fi
}

function debug_begin() {
    debug "🚧 $@"
}

function debug_complete() {
    debug "✅ $@"
}

function debug_fail() {
    debug "❌ $@"
}

function action_error() {
    echo -e >&2 "❌ ${RED}$1${NO_COLOR}"
}

function action_error_exit() {
    action_error "$1. Aborting!"

    exit 1
}

function load_file() {
    debug_begin "Loading $1"

    . "${ROOT_PATH}/${1}" && debug_complete "Loading $1" || (debug_fail "Loading $1" ; return 1)
}

function require_main() {
    if [ "${MAIN_LOADED}" != "1" ]
    then
        echo "File should not be loaded or run directly, please use [update-pritunl.sh]"
        exit 1
    fi
}

function has_tag() {
    if [[ "${REBUILD_TAGS}" -eq "1" ]]
    then
        return 1
    fi

    check=$(echo "${DOCKER_TAGS}" | grep "^$1$")
    if [ "${check}" == "" ]
    then
        return 1
    fi

    return 0
}

function docker_args_reset() {
    DOCKER_ARGS=""
}

function docker_args_append_tag_flags() {
    DOCKER_ARGS+=" --tag ${REPO_NAME_DOCKER_HUB}:$1"
    DOCKER_ARGS+=" --tag ghcr.io/${REPO_NAME_GITHUB}:$1"
    DOCKER_ARGS+=" --tag public.ecr.aws/${REPO_NAME_ECR}:$1"
}

function docker_args_append_build_flags() {
    DOCKER_ARGS+=" --pull"
    DOCKER_ARGS+=" --push"
    DOCKER_ARGS+=" --builder ${DOCKER_BUILDX_NAME}"
    DOCKER_ARGS+=" --platform linux/amd64"
    DOCKER_ARGS+=" --cache-from type=local,src=${DOCKER_CACHE_FOLDER}"
    DOCKER_ARGS+=" --cache-to   type=local,dest=${DOCKER_CACHE_FOLDER}"

    if [ "${DEBUG}" == "0" ]
    then
        DOCKER_ARGS+=" --quiet"
    else
        DOCKER_ARGS+=" --progress=plain"
    fi

    DOCKER_ARGS+=" --build-arg BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    DOCKER_ARGS+=" --build-arg PRITUNL_VERSION=$1"
    DOCKER_ARGS+=" --build-arg UBUNTU_RELEASE=$2"
}
