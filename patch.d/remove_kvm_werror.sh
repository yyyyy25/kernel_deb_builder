#!/bin/bash
sed -i "/CONFIG_KVM_WERROR/s/^/# /g" .config
