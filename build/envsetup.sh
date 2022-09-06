#!/bin/bash
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

# Setup android env
. build/envsetup.sh

# Defs
export VENDOR_EXTRA_PATH=$(gettop)/vendor/extra/
export VENDOR_PATCHES_PATH="$VENDOR_EXTRA_PATH"/build/patches

# Apply patches
. "$VENDOR_PATCHES_PATH"/apply-patches.sh

# functions
los_ota_json() {
    "$VENDOR_EXTRA_PATH"/tools/los_ota_json.py
}

mka_build() {
    # Goofy ahh build env
    unset JAVAC

    # Check is $1 is empty
    if [ -z "$1" ]; then
        echo -e "\nPlease mention the device to build first"
        exit 1
    fi

    # Defs
    DEVICE="$1"
    BUILD_TYPE="userdebug" # ToDo: Don't hardcode it

    # Build
    croot # Make sure we are running this on source rootdir
    lunch lineage_"$DEVICE"-"$BUILD_TYPE"
    mka installclean
    mka bacon -j4

    # Upload build + extras
    cd out/target/product/"$DEVICE"/
    cp lineage-19*.zip ~/public_html/giovanni/"$DEVICE"/
    cp recovery.img ~/public_html/giovanni/"$DEVICE"/
    cp boot.img ~/public_html/giovanni/"$DEVICE"/
    cp obj/PACKAGING/target_files_intermediates/*/IMAGES/vendor_boot.img ~/public_html/giovanni/"$DEVICE"/
    cp dtbo.img ~/public_html/giovanni/"$DEVICE"/

    # Output OTA JSON
    los_ota_json
    croot

    echo -e "\n\nDone!"
}
