#!/usr/bin/env bash

# CONFIG_USER_NS is not set
sed -i "/CONFIG_USER_NS/s/# CONFIG_USER_NS is not set/CONFIG_USER_NS=y/g" .config