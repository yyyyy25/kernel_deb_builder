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
apt install -y wget zstd curl
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

# # get config file from ubuntu ppa
# DEB_FILE=$(curl https://kernel.ubuntu.com/\~kernel-ppa/mainline/v${VERSION_MAJOR}/amd64/ | grep -P -o 'linux-headers-.*?-generic.*?_amd64.deb' | awk 'NR==1{print $1}')
# echo "Fetching ${DEB_FILE} from https://kernel.ubuntu.com/~kernel-ppa/mainline/v${VERSION_MAJOR}/amd64/${DEB_FILE}"
# wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v${VERSION_MAJOR}/amd64/${DEB_FILE}
# ar x ${DEB_FILE}
# if [ -f "data.tar.xz" ]; then
#     tar xf data.tar.xz
# elif [ -f "data.tar.zst" ]; then
#     cat data.tar.zst | zstd -d | tar xf -
# else
#     echo "No data.tar.xz or data.tar.zst found"
#     exit 1
# fi


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
elif [ -f "/build_config" ]; then
    cp /build_config .config
    # cat ../usr/src/linux-headers-*/.config > .config 
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
