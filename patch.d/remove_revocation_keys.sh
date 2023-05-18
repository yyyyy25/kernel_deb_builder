#!/bin/bash
# sed -i "/CONFIG_SYSTEM_REVOCATION_KEYS/s/\".*\"/\"\"/g" .config
# scripts/config --disable SYSTEM_REVOCATION_KEYS
./scripts/config -d CONFIG_SYSTEM_REVOCATION_KEYS
