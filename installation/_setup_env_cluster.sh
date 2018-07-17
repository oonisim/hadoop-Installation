#!/usr/bin/env bash
if [ ! -n "${DIR+1}" ] ; then 
    DIR=$(realpath $(dirname .))
fi

export $(cat ${DIR}/artefacts/hadoop/env/hadoop_variables.sh | grep -v '^#' | xargs)
export $(cat ${DIR}/artefacts/spark/env/spark_variables.sh   | grep -v '^#' | xargs)
