#!/usr/bin/env bash
if [ ! -n "${DIR+1}" ] ; then 
    DIR=$(realpath $(dirname .))
fi

export INSTALL_HOME="${DIR}"
export CONF_DIR="${INSTALL_HOME}/conf"
export TOOL_DIR="${INSTALL_HOME}/tools"

export TARGET_INVENTORY=aws