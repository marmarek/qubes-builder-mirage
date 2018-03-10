#!/bin/bash

if [ "$VERBOSE" -ge 2 -o "$DEBUG" == "1" ]; then
    set -x
fi

set -e

source ./functions.sh >/dev/null
source ./umount_kill.sh >/dev/null

# ==============================================================================
# Cleanup function
# ==============================================================================
function cleanup() {
    errval=$?
    trap - ERR EXIT
    trap
    error "${1:-"${0}: Error.  Cleaning up and un-mounting any existing mounts"}"
    umount_kill "$INSTALLDIR/" || true

    exit $errval
}

trap cleanup ERR EXIT

dev=$(df --output=source $INSTALLDIR | tail -n 1)

# =============================================================================
# partition table and filesystem
# =============================================================================
if [ "0$TEMPLATE_ROOT_WITH_PARTITIONS" -eq 1 ]; then
    # find the right loop device, _not_ its partition
    dev=${dev%p?}

    # convert GPT to MBR partition table, because pvgrub (legacy) can't GPT
    /sbin/sfdisk -d "$dev" |\
        sed -e 's/^label: gpt/label:dos/;/^label-/d;/^device:/d;/-lba: /d;s/type=.*/type=83/' |\
        /sbin/sfdisk "$dev"

    bootdev=${dev}p1
    # pvgrub (legacy) also can't ext4, so create ext2 for it
    /sbin/mkfs.ext2 -F "$bootdev"
    mount "$bootdev" "$INSTALLDIR/boot"
    mkdir -p "${INSTALLDIR}/boot"
    # and create /boot -> . symlink so it doesn't matter if grub looks for
    # /boot/grub or /grub
    ln -s . "$INSTALLDIR/boot/boot"
else
    # pvgrub (lagacy) can't ext4
    umount "$dev"
    /sbin/mkfs.ext2 -F "$dev"
    mount "$dev" "$INSTALLDIR"
    mkdir -p "${INSTALLDIR}/boot"
fi

# =============================================================================
# boot files
# =============================================================================
cp "$MIRAGE_KERNEL_PATH" "$INSTALLDIR/boot/kernel"
mkdir "$INSTALLDIR/boot/grub"
# pvgrub legacy configuration
cp "$SCRIPTSDIR/menu.lst" "$INSTALLDIR/boot/grub/menu.lst"
if [ "0$TEMPLATE_ROOT_WITH_PARTITIONS" -eq 1 ]; then
    sed -i -e 's/(hd0)/(hd0,0)/' "$INSTALLDIR/boot/grub/menu.lst"
fi
# pvgrub2 configuration
cp "$SCRIPTSDIR/grub.cfg" "$INSTALLDIR/boot/grub/grub.cfg"
if [ "0$TEMPLATE_ROOT_WITH_PARTITIONS" -eq 1 ]; then
    sed -i -e 's/(hd0)/(hd0,msdos1)/' "$INSTALLDIR/boot/grub/menu.lst"
fi

# =============================================================================
# things needed by linux-template-builder...
# =============================================================================
mkdir -p "$INSTALLDIR/home"
mkdir -p "$INSTALLDIR/usr/local"
