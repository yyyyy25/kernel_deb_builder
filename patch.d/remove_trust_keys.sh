#!/bin/bash
# sed -i "/CONFIG_SYSTEM_TRUSTED_KEYS/s/^/# /g" .config
scripts/config --disable SYSTEM_TRUSTED_KEYS 
