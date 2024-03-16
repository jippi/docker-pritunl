# shellcheck shell=bash

set -o errexit -o nounset -o pipefail

function print() {
    echo "${OUTPUT_PREFIX:?}" "$@"
}

function debug() {
    [[ "${DEBUG:?}" -gt "0" ]] && echo "${OUTPUT_PREFIX}" "$@"

    return 0
}

function debug_begin() {
    debug "🚧 $*"
}

function debug_complete() {
    debug "✅ $*"
}

function debug_fail() {
    debug "❌ $*"
}

function action_error() {
    echo -e "❌ ${RED:?}$1${NO_COLOR:?}" >&2
}

function action_error_exit() {
    action_error "$1. Aborting!"

    exit 1
}

function has_tag() {
    [[ "${REBUILD_TAGS:?}" -eq "1" ]] && return 1

    check=$(echo "${DOCKER_TAGS:?}" | grep "^$1$")

    [[ "${check}" != "" ]]
}

function docker_args_reset() {
    DOCKER_ARGS=()
}

function docker_args_append_tag_flags() {
    local tag="$1"

    DOCKER_ARGS+=(--tag "${REPO_NAME_DOCKER_HUB}:${tag}")
    DOCKER_ARGS+=(--tag "ghcr.io/${REPO_NAME_GITHUB}:${tag}")
    DOCKER_ARGS+=(--tag "public.ecr.aws/${REPO_NAME_ECR}:${tag}")
}

function docker_args_append_build_flags() {
    local pritunl_version="$1"
    local ubuntu_release="$2"

    DOCKER_ARGS+=(--pull)
    DOCKER_ARGS+=(--push)
    DOCKER_ARGS+=(--builder "${DOCKER_BUILDX_NAME:?}")
    DOCKER_ARGS+=(--sbom true)
    DOCKER_ARGS+=(--attest "type=provenance,mode=max")
    DOCKER_ARGS+=(--platform "$(array::join "," "${BUILD_PLATFORMS[@]}")")
    DOCKER_ARGS+=(--cache-from "type=local,src=${DOCKER_CACHE_FOLDER:?}")
    DOCKER_ARGS+=(--cache-to "type=local,dest=${DOCKER_CACHE_FOLDER:?}")

    if [[ "${DEBUG}" == "0" ]]; then
        DOCKER_ARGS+=(--quiet)
    else
        DOCKER_ARGS+=(--progress plain)
    fi

    DOCKER_ARGS+=(--build-arg "BUILD_DATE=${BUILD_DATE:?}")
    DOCKER_ARGS+=(--build-arg "PRITUNL_VERSION=${pritunl_version}")
    DOCKER_ARGS+=(--build-arg "UBUNTU_RELEASE=${ubuntu_release}")
}

function docker_args_without_mongodb() {
    DOCKER_ARGS+=(--build-arg=MONGODB_VERSION=no)
}

function array::join() {
    local separator="$1"
    shift

    joined=$(printf "${separator}%s" "$@")
    echo "${joined#"${separator}"}"
}
