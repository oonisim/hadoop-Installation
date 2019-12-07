#!/usr/bin/env bash
if [ ! -n "${DIR+1}" ] ; then 
    DIR=$(realpath $(dirname .))
fi
#rsync ${DIR}/artefacts/os/env/hosts ${DIR}/ansible/cluster/02_os/plays/roles/hosts/files/hosts
rsync ${DIR}/conf/ansible/inventories/${TARGET_INVENTORY}/env/os/env/hosts ${DIR}/ansible/cluster/02_os/plays/roles/hosts/files/hosts
