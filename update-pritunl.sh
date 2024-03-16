#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

########################################################################
# Load libraries
########################################################################

source "update-pritunl-config.sh"
source "update-pritunl-bootstrap.sh"
source "update-pritunl-setup.sh"

########################################################################
# Build docker images
########################################################################

debug "github tags: $(echo "${pritunl_releases}" | xargs || true)"
debug "latest tag will be ${latest_release}"

for pritunl_release in ${pritunl_releases}; do
    OUTPUT_PREFIX="[build/${pritunl_release}/default]"

    debug "Considering release"
    if [[ -n "${SKIP[${pritunl_release}]+skip}" ]]; then
        print "🚫 Skipping: ${SKIP[${pritunl_release}]}"
        continue
    fi

    # loop over ubuntu releases we support
    for ubuntu_release in "${UBUNTU_RELEASES[@]}"; do
        tag=${pritunl_release}
        suffix=""

        # change docker tag if we're not building bionic
        if [[ "${ubuntu_release}" != "${DEFAULT_UBUNTU_RELEASE}" ]]; then
            suffix="-${ubuntu_release}"
            tag="${tag}${suffix}"
        fi

        OUTPUT_PREFIX="[build/${pritunl_release}/${ubuntu_release}/default]"
        debug "👷 Processing"

        ####################################################################################
        # build without mongo ("minimal" tag)
        ####################################################################################

        OUTPUT_PREFIX="[build/${pritunl_release}/${ubuntu_release}/minimal]"
        debug "👷 Processing"

        tag+="-minimal"

        # shellcheck disable=SC2310
        if ! has_tag "${tag}"; then
            docker_args_reset
            docker_args_append_build_flags "${pritunl_release}" "${ubuntu_release}"
            docker_args_without_mongodb
            docker_args_append_tag_flags "${tag}"

            if [[ "${pritunl_release}" == "${latest_release}" ]]; then
                OUTPUT_PREFIX="[build/${pritunl_release}/${ubuntu_release}/minimal/latest]"
                print "🏷️  Tagging as latest"
                docker_args_append_tag_flags "latest${suffix}-minimal"
            fi

            debug "Building with tags: [${DOCKER_ARGS[*]}]"

            print "🚧 Building container image"
            start=${SECONDS}
            docker buildx build "${DOCKER_ARGS[@]}" "."
            diff=$((SECONDS - start))
            duration=$(date -ud "@${diff}" "+%H:%M:%S")
            print "✅ Done in ${duration}"
        else
            print "✅ Already build"
        fi
    done

    ####################################################################################
    # build with mongo (default container)
    ####################################################################################

    # shellcheck disable=SC2310
    if ! has_tag "${tag}"; then
        if ! supports_mongodb "${ubuntu_release}"; then
            print "🚫 Skipping: ${ubuntu_release} does not support MongoDB"

            continue
        fi

        docker_args_reset
        docker_args_append_build_flags "${pritunl_release}" "${ubuntu_release}"
        docker_args_append_tag_flags "${tag}"

        if [[ "${pritunl_release}" == "${latest_release}" ]]; then
            OUTPUT_PREFIX="[build/${pritunl_release}/${ubuntu_release}/default/latest]"

            print "🏷️  Tagging as latest"
            docker_args_append_tag_flags "latest${suffix}"
        fi

        print "🚧 Building container image"
        start=${SECONDS}
        docker buildx build "${DOCKER_ARGS[@]}" "."
        diff=$((SECONDS - start))
        duration=$(date -ud "@${diff}" "+%H:%M:%S")
        print "✅ Done in ${duration}"
    else
        print "✅ Already build"
    fi
done

if [[ "${DEBUG}" != "0" ]]; then
    debug_complete "Not flushing caches in debug mode"
    exit 0
fi

print "🚧 Pruning buildx caches"
docker buildx inspect --bootstrap "${DOCKER_BUILDX_NAME}" >/dev/null && docker buildx prune --all --force --builder "${DOCKER_BUILDX_NAME}"
print "✅ Done"

if [[ -d "${DOCKER_CACHE_FOLDER}" ]]; then
    if [[ -d "${DOCKER_CACHE_FOLDER}/ingest" ]]; then
        print "🚧 Pruning buildx exports"
        rm -rf -v "${DOCKER_CACHE_FOLDER}"
        print "✅ Done"
    else
        print "❌ \$DOCKER_CACHE_FOLDER [${DOCKER_CACHE_FOLDER}] does not have an /ingest subfolder, might not be a cache folder after all?"
    fi
fi
