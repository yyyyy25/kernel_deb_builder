#!/usr/bin/env bash

# CONFIG_OVERLAY_FS is not set
sed -i "/CONFIG_OVERLAY_FS/s/# CONFIG_OVERLAY_FS is not set/CONFIG_OVERLAY_FS=y/g" .config