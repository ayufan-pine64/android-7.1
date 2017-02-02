#!/usr/bin/env bash

export USE_CCACHE=true
export CCACHE_DIR=/android/ccache
export ANDROID_JACK_VM_ARGS="-Xmx4g -Dfile.encoding=UTF-8 -XX:+TieredCompilation"

message() {
  echo "============================"
  echo "$@"
  echo "============================"
}

set -ve

message "Installing dependencies..."
apt-get update -y
apt-get install -y software-properties-common

add-apt-repository -y ppa:openjdk-r/ppa
apt-get update -y
apt-get install -y openjdk-${JDK_VERSION}-jdk python git-core gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
  lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
  libgl1-mesa-dev libxml2-utils xsltproc unzip mtools u-boot-tools \
  htop iotop sysstat iftop pigz bc device-tree-compiler lunzip \
  squashfs-tools

message "Downloading repo tool..."
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

message "Downloading manifests..."
mkdir -p /android
cd /android

rm -rf .repo/local_manifests
~/bin/repo init -u https://android.googlesource.com/platform/manifest -b "${MANIFEST}" --depth=1
git clone https://github.com/ayufan-pine64/local_manifests -b "${VARIANT}" .repo/local_manifests

message "Syncing repositories..."
~/bin/repo sync -j 20 -c --force-sync

message "Building squashfs image (repositories)..."
cd /
mksquashfs /android /android.squashfs -Xcompression-level 7

message "Cleanup squashfs mount..."
rm -rf /android

message "Prepare squashfs mount..."
mkdir -p /mnt/android /android/{overlay,work}/

cat <<"EOF" > /etc/rc.local
#!/bin/sh -e
mount -t squashfs /android.squashfs /mnt/android
mount -t overlay overlay -o lowerdir=/mnt/android,upperdir=/android/overlay,workdir=/android/work /android
EOF

message "Mounting squash image..."
/etc/rc.local

message "Configuring ccache..."
cd /android
prebuilts/misc/linux-x86/ccache/ccache -M 0 -F 0

message "Building..."
source build/envsetup.sh
lunch "${BUILD_TARGET}"
make -j $(nproc) || make -j $(nproc) || make -j $(nproc)

message "Cleaning..."
make installclean

message "Updating squashfs..."
cd /
umount /android /mnt/android
mksquashfs /android/overlay /android.squashfs -Xcompression-level 7

message "Cleanup new files..."
rm -rf /android
mkdir -p /android/{overlay,work}/
