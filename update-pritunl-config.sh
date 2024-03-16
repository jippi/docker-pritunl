# shellcheck shell=bash

set -o errexit -o nounset -o pipefail

########################################################################
# Config
########################################################################

declare -gx DEBUG=${DEBUG:-0}

if [[ "${DEBUG}" -eq "2" ]]; then
    set -x
fi

declare -gx BUILD_DATE
BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)

declare -gxri REBUILD_TAGS=${REBUILD_TAGS:-0}
declare -gxri NUMBER_OF_TAGS=${NUMBER_OF_TAGS:-10}
declare -gx OUTPUT_PREFIX="[boot] "
declare -gxr DOCKER_TAG_SOURCE=${DOCKER_TAG_SOURCE:-hub}
declare -gxr DOCKER_CACHE_FOLDER=${DOCKER_CACHE_FOLDER:-/data/local/cache/pritunl-build-cache}
declare -gxr DOCKER_BUILDX_NAME=${DOCKER_BUILDX_NAME:-pritunl-builder}
declare -gxr PUBLIC_ECR_REGISTRY=${PUBLIC_ECR_REGISTRY:-jippi}

# Repository names
declare -gxr REPO_NAME_GITHUB=${REPO_NAME_GITHUB:-jippi/docker-pritunl}
declare -gxr REPO_NAME_ECR=${REPO_NAME_ECR:-jippi/pritunl}
declare -gxr REPO_NAME_DOCKER_HUB=${REPO_NAME_DOCKER_HUB:-jippi/pritunl}

declare -gxr NO_COLOR='\033[0m'
declare -gxr RED='\033[0;31m'

# List of releases to skip
declare -gxrA SKIP=(
    [1.29.2589.95]="no binaries on GitHub"
)

declare -gxr DEFAULT_UBUNTU_RELEASE="focal"

declare -gxra UBUNTU_RELEASES=(
    jammy # 22.04
    focal # 20.04
)

# Docker platforms to build the multi-arch image for
declare -gxra BUILD_PLATFORMS=(
    linux/amd64
)
