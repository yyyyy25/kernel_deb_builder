#!/usr/bin/env bash
# CONFIG_DEBUG_INFO_NONE=y
sed -i "/CONFIG_DEBUG_INFO_NONE/s/y/n/g" .config
# CONFIG_DEBUG_INFO is not set
sed -i "/CONFIG_DEBUG_INFO/s/# CONFIG_DEBUG_INFO is not set/CONFIG_DEBUG_INFO=y/g" .config

grep "CONFIG_DEBUG_INFO=y" .config || echo "CONFIG_DEBUG_INFO=y" >> .config 
grep "CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y" .config || echo "CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y" >> .config
grep "CONFIG_DEBUG_INFO_COMPRESSED_NONE=y" .config || echo "CONFIG_DEBUG_INFO_COMPRESSED_NONE=y" >> .config