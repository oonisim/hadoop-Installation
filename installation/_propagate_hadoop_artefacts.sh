#!/usr/bin/env bash
if [ ! -n "${DIR+1}" ] ; then 
    DIR=$(realpath $(dirname .))
fi
rsync -r --force "${DIR}/artefacts/hadoop/etc" "${DIR}/ansible/cluster/30.spark/plays/roles/common/files/hadoop"