#!/usr/bin/env bash
if [ ! -n "${DIR+1}" ] ; then 
    DIR=$(realpath $(dirname .))
fi
${DIR}/_setup_env_installer.sh
${DIR}/_setup_env_aws.sh
${DIR}/_setup_env_cluster.sh
