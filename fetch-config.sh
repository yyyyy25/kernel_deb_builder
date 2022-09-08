#!/usr/bin/env bash

# get version_major
if [ "${VERSION: -2}" = ".0" ]; then
    VERSION_MAJOR="${VERSION:0: -2}"
else
    VERSION_MAJOR="${VERSION}"
fi

if [ -f config-${VERSION} ]; then
    cp config-${VERSION} .config
else
    mkdir -p .fetch_config
    cd .fetch_config || exit

    # get config file from ubuntu ppa
    DEB_FILE=$(curl https://kernel.ubuntu.com/\~kernel-ppa/mainline/v${VERSION_MAJOR}/amd64/ | grep -P -o 'linux-headers-.*?-generic.*?_amd64.deb' | awk 'NR==1{print $1}')
    echo "Fetching ${DEB_FILE} from https://kernel.ubuntu.com/~kernel-ppa/mainline/v${VERSION_MAJOR}/amd64/${DEB_FILE}"
    wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v${VERSION_MAJOR}/amd64/${DEB_FILE}
    ar x ${DEB_FILE}
    if [ -f "data.tar.xz" ]; then
        tar xf data.tar.xz
    elif [ -f "data.tar.zst" ]; then
        cat data.tar.zst | zstd -d | tar xf -
    else
        echo "No data.tar.xz or data.tar.zst found"
        exit 1
    fi

    cd ..
    cp .fetch_config/usr/src/linux-headers-*/.config ./.config
fi

GCC_VERSION=$(cat .config | sed -n 's/CONFIG_CC_VERSION_TEXT=".*\s\(.*\)"$/\1/p')
GCC_VERSION_MAJOR=$(echo "${GCC_VERSION}" | sed -En 's/(.*).[0-9]+/\1/p')

rm -rf .fetch_config