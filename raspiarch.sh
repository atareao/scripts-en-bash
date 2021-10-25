#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# Copyright (c) 2021 Lorenzo Carbonell <a.k.a. atareao>

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

SOURCE=http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz
MNTDIR=/mnt/arch
TEMPDIR=/tmp/raspiarch
TARBALL=raspiarch.tar.gz

if [[ ! -f "${TEMPDIR}/${TARBALL}" ]]
then
    echo "### Init ###"
    if [[ -d "${TEMPDIR}" ]]
    then
        rm -rf "${TEMPDIR}"
    fi
    if [[ -d "${MNTDIR}" ]]
    then
        rm -rf "${MNTDIR}"
    fi
    mkdir "${TEMPDIR}"
    mkdir "${MNTDIR}"
    echo "### Get tarball ###"
    mkdir -p ${TEMPDIR}
    wget ${SOURCE} -O ${TEMPDIR}/${TARBALL}
fi
echo "### Create filesystem ###"
parted /dev/sdb --script -- mklabel msdos
parted /dev/sdb --script -- mkpart primary fat32 1 256
parted /dev/sdb --script -- mkpart primary ext4 256 100%
parted /dev/sdb --script -- set 1 boot on
parted /dev/sdb --script print
mkfs.vfat -F32 /dev/sdb1
mkfs.ext4 -F /dev/sdb2
echo "### Copy tarball  content"
mkdir -p ${MNTDIR}/{boot,root}
mount /dev/sdb1 ${MNTDIR}/boot
mount /dev/sdb2 ${MNTDIR}/root
tar xvzf ${TEMPDIR}/${TARBALL} -C ${MNTDIR}/root
mv ${MNTDIR}/root/boot/* ${MNTDIR}/boot
echo "### Change mmcblk ###"
sed -i 's/mmcblk0/mmcblk1/g' ${MNTDIR}/root/etc/fstab
umount ${MNTDIR}/boot
umount ${MNTDIR}/root
echo "### Cleaning ###"
rm -rf ${MNTDIR}
rm -rf ${TEMPDIR}
