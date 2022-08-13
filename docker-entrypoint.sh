#!/usr/bin/env bash

# add deb-src to sources.list
# sed -i "/deb-src/s/# //g" /etc/apt/sources.list
cat <<EOF > /etc/apt/sources.list
deb https://deb.debian.org/debian/ bullseye main contrib non-free
deb-src https://deb.debian.org/debian/ bullseye main contrib non-free
deb https://deb.debian.org/debian/ bullseye-updates main contrib non-free
deb-src https://deb.debian.org/debian/ bullseye-updates main contrib non-free

deb https://deb.debian.org/debian/ bullseye-backports main contrib non-free
deb-src https://deb.debian.org/debian/ bullseye-backports main contrib non-free

deb https://deb.debian.org/debian-security bullseye-security main contrib non-free
deb-src https://deb.debian.org/debian-security bullseye-security main contrib non-free
EOF

# install dep
apt update
apt install -y wget zstd curl
apt build-dep -y linux

# change dir to workplace
cd "/linux-${VERSION}" || exit

if [ "${VERSION: -2}" = ".0" ]; then
    VERSION_MAJOR="${VERSION:0: -2}"
else
    VERSION_MAJOR="${VERSION}"
fi

# get condig file from ubuntu ppa
DEB_FILE=$(curl https://kernel.ubuntu.com/\~kernel-ppa/mainline/v${VERSION_MAJOR}/amd64/ | grep -P -o 'linux-headers-.*?-generic.*?_amd64.deb' | awk 'NR==1{print $1}')
wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v${VERSION_MAJOR}/amd64/${DEB_FILE}
ar x ${DEB_FILE}
cat data.tar.zst | zstd -d | tar xf -


# download kernel source
wget http://www.kernel.org/pub/linux/kernel/v${VERSION: 0: 1}.x/linux-"${VERSION_MAJOR}".tar.xz -O linux-"${VERSION}".tar.xz
tar -xf linux-"${VERSION}".tar.xz

if [ "${VERSION}" != "${VERSION_MAJOR}" ]; then
    mv linux-"${VERSION_MAJOR}" linux-"${VERSION}"
fi

cd linux-"${VERSION}" || exit

# copy config file
if [ -f "/config-${VERSION}" ]; then
    cp "/config-${VERSION}" .config
else
    cat ../usr/src/linux-headers-*/.config > .config 
fi


# disable DEBUG_INFO to speedup build
# scripts/config --disable DEBUG_INFO

# apply patches
# shellcheck source=src/util.sh
ls -al /patch.d
source /patch.d/*.sh

# build deb packages
CPU_CORES=$(($(grep -c processor < /proc/cpuinfo)*2))
make deb-pkg -j"$CPU_CORES"

# move deb packages to artifact dir
# cd ..
# mkdir "build_target_debs"
# mv ../*.deb build_target_debs/
