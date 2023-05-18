#!/usr/bin/env bash
# CONFIG_DEBUG_INFO_BTF=y
# CONFIG_DEBUG_INFO_BTF_MODULES=y

VERSION_HEADER=$(echo "${VERSION}" | sed -En 's/(.*).[0-9]+/\1/p')
if [[ "${VERSION_HEADER}" == "5.12" || "${VERSION_HEADER}" == "5.13" ]]; then
    # sed -i "/CONFIG_DEBUG_INFO_BTF/s/y/n/" .config
    ./scripts/config -d CONFIG_DEBUG_INFO_BTF
fi