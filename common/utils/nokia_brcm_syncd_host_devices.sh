#!/bin/bash
# Emit docker create flags for Nokia BDB devices into hardened Broadcom syncd
# containers (see sonic-buildimage #29704 BRCM_DEV_MNT).

extra=""
#--device = pass the driver character device so SDK can control/access BDB.
if [ -e /dev/nokia-kernel-bdb ]; then
    extra="--device=/dev/nokia-kernel-bdb:/dev/nokia-kernel-bdb:rwm"
fi
#--mount proc = pass one proc file so user-space can read kernel-published BDB state if the container doesn�t already see it
#if [ -e /proc/nokia-kernel-bdb ]; then
#    extra="$extra --mount=type=bind,source=/proc/nokia-kernel-bdb,destination=/proc/nokia-kernel-bdb,readonly"
#fi
printf '%s' "$extra"
