#!/bin/bash
# sed -i "/CONFIG_KVM_WERROR/s/=y/=n/g" .config
./scripts/config -d CONFIG_KVM_WERROR