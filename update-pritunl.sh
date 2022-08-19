#!/usr/bin/env bash

set -e
set -o pipefail

MAIN_LOADED=1
OUTPUT_PREFIX="[boot] "

########################################################################
# Load libraries
########################################################################

source update-pritunl-bootstrap.sh

load_file ./update-pritunl-config.sh
load_file ./update-pritunl-setup.sh

########################################################################
# Build docker images
########################################################################

debug "github tags: $(echo $pritunl_releases | xargs)"
debug "latest tag will be ${latest_release}"

for pritunl_release in $pritunl_releases
do
    OUTPUT_PREFIX="[${pritunl_release}/default]"

    debug "Considering release"
    if [[ " ${SKIP[*]} " =~ " ${pritunl_release} " ]]
    then
        print "Skipping ....";
        continue
    fi

    # loop over ubuntu releases we support
    for ubuntu_release in bionic focal
    do
        tag=${pritunl_release}
        suffix=""

        # change docker tag if we're not building bionic
        if [ "${ubuntu_release}" != "bionic" ]; then
            suffix="-${ubuntu_release}"
            tag="${tag}${suffix}"
        fi

        OUTPUT_PREFIX="[${pritunl_release}/${ubuntu_release}/default]"
        debug "👷 Processing"

        ####################################################################################
        # build with mongo (default container)
        ####################################################################################

        if ! has_tag $tag
        then
            docker_args_reset
            docker_args_append_build_flags $pritunl_release $ubuntu_release
            docker_args_append_tag_flags $tag

            if [ "${pritunl_release}" == "${latest_release}" ]
            then
                OUTPUT_PREFIX="[${pritunl_release}/${ubuntu_release}/default/latest]"

                print "🏷️  Tagging as latest"
                docker_args_append_tag_flags "latest${suffix}"
            fi

            print "🚧 Building container image"
            docker buildx build $DOCKER_ARGS .
            print "✅ Done"
        else
            print "✅ Already build"
        fi

        ####################################################################################
        # build without mongo ("minimal" tag)
        ####################################################################################

        OUTPUT_PREFIX="[${pritunl_release}/${ubuntu_release}/minimal]"
        debug "👷 Processing"

        tag+="-minimal"

        if ! has_tag $tag
        then
            docker_args_reset
            docker_args_append_build_flags $pritunl_release $ubuntu_release
            docker_args_append_tag_flags $tag

            if [ "${pritunl_release}" == "${latest_release}" ]
            then
                OUTPUT_PREFIX="[${pritunl_release}/${ubuntu_release}/minimal/latest]"
                print "🏷️ Tagging as latest"
                docker_args_append_tag_flags "latest${suffix}-minimal"
            fi

            debug "Building with tags: [${DOCKER_ARGS}]"

            print "🚧 Building container image"
            docker buildx build ${DOCKER_ARGS} --build-arg=MONGODB_VERSION=no .
            print "✅ Done"
        else
            print "✅ Already build"
        fi
    done
done

if [ "$DEBUG" != "0" ]
then
    debug_complete "Not flushing caches in debug mode"
    exit 0
fi

print "🚧 Pruning buildx caches"
docker buildx prune --all --force --builder $DOCKER_BUILDX_NAME
print "✅ Done"

print "🚧 Pruning buildx exports"
rm -rf -v "${DOCKER_CACHE_FOLDER}"
print "✅ Done"
