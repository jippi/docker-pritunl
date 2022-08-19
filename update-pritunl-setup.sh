require_main

OUTPUT_PREFIX="[setup]"

########################################################################
# Docker registry authentication
########################################################################

# ECR
if ! curl -s -S --fail --header "Authorization: Basic $(jq -r '.auths["'public.ecr.aws'"]["auth"]' ~/.docker/config.json)" public.ecr.aws/${PUBLIC_ECR_REGISTRY} > /dev/null
then
    debug "🔒 Logging in to AWS registry ..."
    aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/${PUBLIC_ECR_REGISTRY}
    debug_complete "Login to AWS registry successful"
else
    debug_complete "Already logged in to AWS registry"
fi

# GitHub
if ! curl -s -S --fail --header "Authorization: Bearer $(jq -r '.auths["'ghcr.io'"]["auth"]' ~/.docker/config.json)" "https://ghcr.io/v2/${REPO_NAME_GITHUB}/manifests/latest" > /dev/null
then
    debug "🔒 Logging in to GitHub registry ..."
    if [ -z "${CR_PAT}" ]
    then
        debug_fail "Missing \$CR_PAT env key"
        exit 1
    fi

    echo $CR_PAT | docker login ghcr.io -u jippi --password-stdin > /dev/null
    debug_complete "Login to GitHub registry successful"
else
    debug_complete "Already logged in to GitHub registry"
fi

########################################################################
# Build context
########################################################################

# Create buildx context
(
    docker buildx create --name $DOCKER_BUILDX_NAME --driver docker-container > /dev/null 2>&1 \
    && debug_complete "buildx container builder created"
) || debug_complete "buildx container builder exists"

########################################################################
# Remote state
########################################################################

# find most recent docker tags from Docker Hub
debug_begin "Loading docker tags"
DOCKER_TAGS=$(curl -s "https://hub.docker.com/v2/repositories/${REPO_NAME_DOCKER_HUB}/tags/?page_size=100" | jq -r '.results[].name' | sort --numeric-sort)
debug_complete "Loading docker tags"

# find latest relases from pritunl/pritunl repository
debug_begin "Loading pritunl/pritunl releases"
pritunl_releases=$(curl -s https://api.github.com/repos/pritunl/pritunl/tags | jq -r '.[].name' | sort --reverse --numeric-sort | head -10)
latest_release=$(echo "${pritunl_releases}" | head -1)
debug_complete "Loading pritunl/pritunl releases"

mkdir -p ${DOCKER_CACHE_FOLDER}
