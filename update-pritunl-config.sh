# shellcheck shell=bash

set -o errexit -o nounset -o pipefail

########################################################################
# Config
########################################################################

declare -gx DEBUG=${DEBUG:-0}

if [[ "${DEBUG}" -eq "2" ]]; then
    set -x
fi

declare -gx REBUILD_TAGS=${REBUILD_TAGS:-0}
declare -gx OUTPUT_PREFIX="[boot] "
declare -gx DOCKER_TAG_SOURCE=${DOCKER_TAG_SOURCE:-hub}
declare -gx DOCKER_CACHE_FOLDER=${DOCKER_CACHE_FOLDER:-/data/local/cache/pritunl-build-cache}
declare -gx DOCKER_BUILDX_NAME=${DOCKER_BUILDX_NAME:-pritunl-builder}
declare -gx PUBLIC_ECR_REGISTRY=${PUBLIC_ECR_REGISTRY:-jippi}

# Repository names
declare -gx REPO_NAME_GITHUB=${REPO_NAME_GITHUB:-jippi/docker-pritunl}
declare -gx REPO_NAME_ECR=${REPO_NAME_ECR:-jippi/pritunl}
declare -gx REPO_NAME_DOCKER_HUB=${REPO_NAME_DOCKER_HUB:-jippi/pritunl}

declare -gx NO_COLOR='\033[0m'
declare -gx RED='\033[0;31m'

# List of releases to skip
declare -gxA SKIP=(
    [1.29.2589.95]="no binaries on GitHub"
)

declare -gx DEFAULT_UBUNTU_RELEASE="focal"

declare -gxa UBUNTU_RELEASES=(
    jammy # 22.04
    focal # 20.04
)
