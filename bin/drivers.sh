#!/usr/bin/env bash

set -euo pipefail

facetimehd() {
    lsmod | grep "facetimehd " && exit 0

    echo get dependencies
    sudo apt install -y --auto-remove \
         cpio debhelper dkms kmod libssl-dev xz-utils

    echo install firmware
    cd /tmp
    git clone https://github.com/patjak/facetimehd-firmware
    cd facetimehd-firmware
    make
    sudo make install

    echo get driver code
    cd /usr/src
    sudo git clone https://github.com/patjak/bcwc_pcie

    echo check dkms.conf, rename driver dir
    MOD="$(grep PACKAGE_NAME bcwc_pcie/dkms.conf | cut -f2 -d"=")"
    VSN="$(grep PACKAGE_VERSION bcwc_pcie/dkms.conf | cut -f2 -d"=")"
    echo driver is "$MOD-$VSN"
    sudo rm -rf "$MOD-$VSN"
    sudo mv bcwc_pcie "$MOD-$VSN"
    cd "$MOD-$VSN"
    sudo make clean
    echo Register the new module with DKMS:
    sudo dkms add -m "$MOD" -v "$VSN"
    echo Build the module:
    sudo dkms build -m "$MOD" -v "$VSN"
    echo Build a Debian source package:
    sudo dkms mkdsc -m "$MOD" -v "$VSN" --source-only
    echo Build a Debian binary package:
    sudo dkms mkdeb -m "$MOD" -v "$VSN" --source-only
    echo Copy deb locally:
    sudo cp /var/lib/dkms/"$MOD"/"$VSN"/deb/"$MOD"-dkms_"$VSN"_all.deb /root
    echo Get rid of the local build files:
    sudo rm -r /var/lib/dkms/"$MOD"
    echoInstall the new deb package:
    sudo dpkg -i /root/"$MOD"-dkms_"$VSN"_all.deb
    echo load the module
    sudo modprobe "$MOD"
}

wl() {
    lsmod | grep "wl " && exit 0

    sudo apt-get install -y --auto-remove \
         broadcom-sta-dkms
    sudo modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
    sudo modprobe wl
}

VSN="$(uname -r|sed 's,[^-]*-[^-]*-,,')"
sudo apt-get install -y --auto-remove \
     linux-image-"$VSN" linux-headers-"$VSN"

lspci | grep Network | grep -q BCM4360 && wl
lspci | grep Multimedia | grep -q "FaceTime HD" && facetimehd
