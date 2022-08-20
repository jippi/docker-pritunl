#!/usr/bin/env bash

set -e

######################################################################
# CHANGE ME
######################################################################

# must point to the directory where files like `mongod.lock` and `journal/` are on disk.
#
# PLEASE  MAKE A BACKUP OF YOUR DATA FIRST!
MONGODB_DATA_PATH=${MONGODB_DATA_PATH:-}

# Comment/uncomment the versions you want to upgrade through.
#
# If you use the old Docker images, you're coming from 3.2, so your first version is 3.4
# and depending on what Docker image you plan to use, either stop at 4.4 or 5.0
#
# Don't worry, the script will ask for confirmation before each upgrade step
UPGRADE_PATH=( \
    "3.4" # https://www.mongodb.com/docs/manual/release-notes/3.4-upgrade-standalone/#prerequisites
    "3.6" # https://www.mongodb.com/docs/manual/release-notes/3.6-upgrade-standalone/#prerequisites
    "4.0" # https://www.mongodb.com/docs/manual/release-notes/4.0-upgrade-standalone/#prerequisites
    "4.2" # https://www.mongodb.com/docs/manual/release-notes/4.2-upgrade-standalone/#prerequisites
    "4.4" # <- stop here if you use "Bionic (18.04)" https://www.mongodb.com/docs/manual/release-notes/4.4-upgrade-standalone/#prerequisites
    "5.0" # <- stop here if you use "Focal (20.04)"  https://www.mongodb.com/docs/manual/release-notes/5.0-upgrade-standalone/#prerequisites
)

# change to "yes" for the script to work
I_TOOK_A_BACKUP_OF_MY_DATA=${I_TOOK_A_BACKUP_OF_MY_DATA:-no}

######################################################################
# Script
######################################################################

MONGODB_CONTAINER_NAME="temp-mongo-server"

function stop_server() {
    if docker ps | grep --quiet "$MONGODB_CONTAINER_NAME"
    then
        echo "==> Stopping MongoDB gracefully ..."
        docker exec -it "$MONGODB_CONTAINER_NAME" mongo admin --quiet --eval "db.shutdownServer()" || true

        count=0
        while true
        do
            if ! docker ps | grep --quiet "$MONGODB_CONTAINER_NAME"
            then
                echo "====> MongoDB shut down gracefully..."
                break
            fi

            sleep 1
            count=$(( $count + 1 ))

            if [ "$count" -gt 10 ]
            then
                echo "====> MongoDB did not shut down gracefully..."
                break
            fi
        done
    fi

    echo "==> Removing container"
    docker rm -f $MONGODB_CONTAINER_NAME > /dev/null 2>&1 || true

    return 0
}

function upgrade() {
    local compat_version=$1

    echo "Please answer with: "
    echo " 'y' for 'yes'"
    echo " 's' for 'skip this upgrade"
    echo " 'q' for 'quit'"
    echo ""

    while true
    do
        read -p "Upgrade to ${compat_version}? [y/s/q]: " confirm_upgrade
        if [ "$confirm_upgrade" == "s" ]; then
            echo "==> Skipping upgrade ${compat_version}!"
            echo ""
            return 0
        fi

        if [ "${confirm_upgrade,,}" == "q" ]; then
            echo "==> Aborting all upgrades"
            exit 1
        fi

        if [ "${confirm_upgrade,,}" == "y" ]; then
            break
        fi

        echo "Uknown answer, please try again"
    done

    echo ""

    stop_server

    echo "==> Starting server (${compat_version})"
    docker run --detach --name $MONGODB_CONTAINER_NAME --volume ${MONGODB_DATA_PATH}:/data/db mongo:${compat_version} > /dev/null

    echo "==> Changing server compatability (v${compat_version})"
    sleep 3

    count=0
    while true
    do
        if docker exec $MONGODB_CONTAINER_NAME mongo admin --quiet --eval "var result = db.adminCommand( { setFeatureCompatibilityVersion: \"$compat_version\" } ); if (!result.ok) { throw(result.errmsg) }"
        then
            break
        fi

        sleep 1
        count=$(( $count +1 ))

        logs=$(docker logs $MONGODB_CONTAINER_NAME)
        if echo "$logs" | grep --silent -i "unsupported WiredTiger file version"
        then
            echo ""
            echo "Oh dear.."
            echo ""
            echo "It looks like the server failed to start due to the server running a version that can't read the files"
            echo "This is likely because the server is either too new or too old - in this case, we'll assume the files has already been upgraded, so skipping on to the next version"
            echo ""
            echo "Server logs:"
            echo ""
            echo "$logs" | grep -C 1000 --color -E 'unsupported WiredTiger file version'
            echo ""

            return 0
        fi

        if [ "$count" -gt 10 ]
        then
            echo ""
            echo "Could not change compat after 10 attempts, server failed to start!"
            echo ""
            echo "This could be due to this migration already have been applied, check the logs for the error"
            echo ""
            echo "  'unsupported WiredTiger file version: this build ....'"
            echo ""
            echo "Server logs:"
            echo ""
            echo "$logs" | grep -C 1000 --color -E 'unsupported WiredTiger file version'
            echo ""

            return 0
        fi
    done

    stop_server

    # repair server
    echo "==> Doing repair of data post-upgrade (v${compat_version}) ..."
    logs=$(docker run --rm --volume ${MONGODB_DATA_PATH}:/data/db mongo:${compat_version} --repair)
    if [ "$?" != "0" ]; then
        echo ""
        echo "DB repair failed...."
        echo ""
        echo -en "$logs" | grep --color -E -C 1000 "IMPORTANT: UPGRADE PROBLEM:"

        echo ""
        echo "==========================================================================="
        echo "MongoDB upgrade to ${compat_version} FAILED!"
        echo "==========================================================================="
        echo ""

        exit 1
    fi

    echo ""
    echo "==========================================================================="
    echo "MongoDB upgrade to ${compat_version} SUCCESS!"
    echo "==========================================================================="
    echo ""
}

# faking a 3.2 start
# if [ ! -e "$MONGODB_DATA_PATH" ]
# then
#     stop_server
#     docker run --detach --name $MONGODB_CONTAINER_NAME --volume ${MONGODB_DATA_PATH}:/data/db mongo:3.2 > /dev/null
#     stop_server
# fi

# please make a backup, please....!
if [ "$I_TOOK_A_BACKUP_OF_MY_DATA" != "yes" ]
then
    echo "Please change \$I_TOOK_A_BACKUP_OF_MY_DATA to 'yes' for the script to work"
    exit 1
fi

# check if the data path looks like a mongo data dir
if [ ! -d "$MONGODB_DATA_PATH/journal" ]
then
    echo "\$MONGODB_DATA_PATH path '$MONGODB_DATA_PATH' does not look like a MongoDB data folder, no 'journal/' folder found"
    exit 1
fi

echo "==========================================================================="
echo "Information"
echo "==========================================================================="
echo ""
echo "Hello!"
echo ""
echo "This script will guide you through a MongoDB upgrade path through the following versions:"
echo ""
for version in "${UPGRADE_PATH[@]}"
do
    echo "* $version"
done
echo ""
echo "You will be asked to confirm before each upgrade step, and the script will do it best to provide guidance and tips if something bad happens..."
echo ""
echo "Good luck! :)"
echo ""
echo "==========================================================================="
echo "Lets us begin!"
echo "==========================================================================="

# do the upgrades
for version in "${UPGRADE_PATH[@]}"
do
	upgrade "$version"
done

echo "All upgrades completed"
