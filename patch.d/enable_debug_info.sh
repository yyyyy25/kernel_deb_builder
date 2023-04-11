#!/usr/bin/env bash

# CONFIG_DEBUG_INFO is not set
sed -i "/CONFIG_DEBUG_INFO/s/# CONFIG_DEBUG_INFO is not set/CONFIG_DEBUG_INFO=y/g" .config

# CONFIG_DEBUG_INFO_NONE=y
sed -i "/CONFIG_DEBUG_INFO_NONE/s/y/n/g" .config