#!/usr/bin/env bash
if [ ! -n "${DIR+1}" ] ; then 
    DIR=$(realpath $(dirname .))
fi
#rsync -r --force "${DIR}/artefacts/hadoop/etc" "${DIR}/ansible/cluster/30_spark/plays/roles/common/files/hadoop"
rsync -r --force "${DIR}/conf/ansible/inventories/${TARGET_INVENTORY}/env/hadoop/etc" "${DIR}/ansible/cluster/30_spark/plays/roles/common/files/hadoop"
