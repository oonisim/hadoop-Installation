#!/usr/bin/env bash
set -u
if [ ! -n "${DIR+1}" ] ; then
    DIR=$(realpath $(dirname .))
fi

#export $(cat ${DIR}/artefacts/hadoop/env/hadoop_variables.sh | grep -v '^#' | xargs)
#export $(cat ${DIR}/artefacts/spark/env/spark_variables.sh   | grep -v '^#' | xargs)

export TARGET_INVENTORY=${TARGET_INVENTORY:?"Set TARGET_INVENTORY"}

export $(cat ${DIR}/conf/ansible/inventories/${TARGET_INVENTORY}/env/hadoop/env/hadoop_variables.sh | grep -v '^#' | xargs)
export $(cat ${DIR}/conf/ansible/inventories/${TARGET_INVENTORY}/env/spark/env/spark_variables.sh   | grep -v '^#' | xargs)
