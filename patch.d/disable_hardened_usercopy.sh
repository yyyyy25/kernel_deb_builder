#!/usr/bin/env bash
# CONFIG_HARDENED_USERCOPY=y
# sed -i "/CONFIG_HARDENED_USERCOPY/s/y/n/" .config
./scripts/config -d CONFIG_HARDENED_USERCOPY 