#!/usr/bin/env bash

#debug release version
OS_RELEASE=$(cat /etc/os-release | grep "VERSION_CODENAME" | cut -d '=' -f 2)

# add deb-src to sources.list
if [[ "${OS_RELEASE}" == "bullseye" || "${OS_RELEASE}" == "testing" ]]; then
cat <<EOF > /etc/apt/sources.list
deb https://deb.debian.org/debian/ $OS_RELEASE main contrib non-free
deb-src https://deb.debian.org/debian/ $OS_RELEASE main contrib non-free
deb https://deb.debian.org/debian/ $OS_RELEASE-updates main contrib non-free
deb-src https://deb.debian.org/debian/ $OS_RELEASE-updates main contrib non-free

deb https://deb.debian.org/debian/ $OS_RELEASE-backports main contrib non-free
deb-src https://deb.debian.org/debian/ $OS_RELEASE-backports main contrib non-free

deb https://deb.debian.org/debian-security $OS_RELEASE-security main contrib non-free
deb-src https://deb.debian.org/debian-security $OS_RELEASE-security main contrib non-free
EOF
elif [[ "${OS_RELEASE}" == "buster" || "${OS_RELEASE}" == "stretch" ]]; then
cat <<EOF > /etc/apt/sources.list
deb https://deb.debian.org/debian/ $OS_RELEASE main contrib non-free
deb-src https://deb.debian.org/debian/ $OS_RELEASE main contrib non-free
deb https://deb.debian.org/debian/ $OS_RELEASE-updates main contrib non-free
deb-src https://deb.debian.org/debian/ $OS_RELEASE-updates main contrib non-free

deb https://deb.debian.org/debian/ $OS_RELEASE-backports main contrib non-free
deb-src https://deb.debian.org/debian/ $OS_RELEASE-backports main contrib non-free

deb https://deb.debian.org/debian-security $OS_RELEASE/updates main contrib non-free
deb-src https://deb.debian.org/debian-security $OS_RELEASE/updates main contrib non-free
EOF
else
echo "Unsupported OS_RELEASE: ${OS_RELEASE}"
exit 1
fi

# install dep
apt update
apt install -y wget zstd curl git
if [ "${OS_RELEASE}" = "bullseye" ]; then
    apt build-dep -y linux
else
    apt install build-essential libncurses-dev bison flex libssl-dev libelf-dev bc kmod cpio fakeroot rsync lz4 dwarves -y
fi
# change dir to workplace
cd "/linux-${VERSION}" || exit

if [ "${VERSION: -2}" = ".0" ]; then
    VERSION_MAJOR="${VERSION:0: -2}"
else
    VERSION_MAJOR="${VERSION}"
fi


# git version
if [ $(echo -n "${VERSION}" | grep -E '^[0-9a-fA-F]+$') ]; then
    if [ -z "${KERNEL_FETCH_URL}" ]; then
        echo "KERNEL_FETCH_URL is not set"
        exit 1
    fi
    git clone "${KERNEL_FETCH_URL}" "linux-${VERSION}"
    cd "linux-${VERSION}" || exit
    git checkout "${VERSION}"
# number version
elif [ $(echo -n "${VERSION}" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$') ]; then

    if [ -z "${KERNEL_FETCH_URL}" ]; then
        KERNEL_FETCH_URL="http://www.kernel.org/pub/linux/kernel/v${VERSION: 0: 1}.x/linux-${VERSION_MAJOR}.tar.xz"
    fi

    if [ $(echo -n "${KERNEL_FETCH_URL}" | grep -E '^git') ] || [ $(echo -n "${KERNEL_FETCH_URL}" | grep -E 'git$') ]; then
        # clone git repo
        echo git clone "${KERNEL_FETCH_URL}" "linux-${VERSION}"
        git clone "${KERNEL_FETCH_URL}" "linux-${VERSION}"
        cd "linux-${VERSION}" || exit
        git checkout "${VERSION}"
    else
        # download source from mirror
        wget $KERNEL_FETCH_URL -O linux-"${VERSION}".tar.xz
        tar -xf linux-"${VERSION}".tar.xz

        if [ "${VERSION}" != "${VERSION_MAJOR}" ]; then
            mv linux-"${VERSION_MAJOR}" linux-"${VERSION}"
        fi

        cd linux-"${VERSION}" || exit
    fi

fi

# copy config file
if [ -f "/config-${VERSION}" ]; then
    cp "/config-${VERSION}" .config
elif [ -f "/build_config" ]; then
    cp /build_config .config
fi

# apply patches
# shellcheck source=src/util.sh
for PATCH in /patch.d/*.sh; do
    echo "Applying patch ${PATCH}"
    source "${PATCH}"
done

# check the final config
grep -r "\-Werror"
cat .config

# build deb packages
CPU_CORES=$(($(grep -c processor < /proc/cpuinfo)*2))
make deb-pkg -j"$CPU_CORES"

# move deb packages to artifact dir
# cd ..
# mkdir "build_target_debs"
# mv ../*.deb build_target_debs/

