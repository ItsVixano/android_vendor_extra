#!/bin/bash
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

# Setup android env
. build/envsetup.sh

# Defs
export LOS_VERSION=$(grep "PRODUCT_VERSION_MAJOR" "$ANDROID_BUILD_TOP"/vendor/lineage/config/version.mk | sed 's/PRODUCT_VERSION_MAJOR = //g' | head -1)
export VENDOR_EXTRA_PATH=$(gettop)/vendor/extra
export VENDOR_PATCHES_PATH="$VENDOR_EXTRA_PATH"/build/patches
export VENDOR_PATCHES_PATH_VERSION="$VENDOR_PATCHES_PATH"/lineage"$LOS_VERSION"

# Apply patches
if [[ "$1" = "-p" || "$1" = "--apply-patches" ]]; then
    . "$VENDOR_PATCHES_PATH"/apply-patches.sh
fi

# functions
upload_assets() {
    # Check is $1 is empty
    if [ -z "$1" ]; then
        echo -e "\nPlease mention the device codename first"
        return 0
    fi

    # Defs
    DEVICE="$1"

    # Upload assets
    cd out/target/product/"$DEVICE"/ &> /dev/null
    for file in lineage-*.zip recovery.img boot.img obj/PACKAGING/target_files_intermediates/*/IMAGES/vendor_*.img dtbo.img; do
        echo -e "\nUploading $file\n"
        curl -T $file https://oshi.at
    done

    # Return to the root dir
    croot
}

los_ota_json() {
    # Check is $1 is empty
    if [ -z "$1" ]; then
        echo -e "\nPlease mention the device codename first"
        return 0
    fi

    # Defs
    DEVICE="$1"

    # Generate the OTA Json
    croot
    cd out/target/product/"$DEVICE"/ &> /dev/null
    "$VENDOR_EXTRA_PATH"/tools/los_ota_json.py

    # Return to source root dir
    croot
}

mka_build() {
    # Check is $1 is empty
    if [[ -z "$1" || "$1" = "-d" || "$1" = "--dirty" ]]; then
        echo -e "\nPlease mention the device to build first"
        return 0
    fi

    # Defs
    DEVICE="$1"
    BUILD_TYPE="userdebug" # ToDo: Don't hardcode it
    if [[ "$2" = "-d" || "$2" = "--dirty" ]]; then
        echo -e "\nWarning: Building without cleaning up $DEVICE out dir\n"
        rm -rf out/target/product/"$DEVICE"/lineage-*.zip &> /dev/null
        DIRTY_BUILD="no"
    else
        echo -e "\nWarning: Building with cleaned up $DEVICE out dir\n"
        DIRTY_BUILD="yes"
    fi

    # Conditionally disable ripple animation
    if [[ "$LOS_VERSION" = "20" ]]; then
        if [[ "$DEVICE" = "lisa" ]]; then
            echo -e "Re-enable ripple animation for $DEVICE"
            PATCH_REVERT="Revert-"
        else
            echo -e "Disable ripple animation for $DEVICE"
            PATCH_REVERT=""
        fi
        cd "$ANDROID_BUILD_TOP"/frameworks/base
        git am "$VENDOR_PATCHES_PATH_VERSION"/frameworks_base/ripple/0001-"$PATCH_REVERT"base-Disable-ripple-effect-on-unlock.patch
        git am --abort &> /dev/null
        echo -e "\n"
    fi

    croot
    sleep 3

    # Build
    lunch lineage_"$DEVICE"-"$BUILD_TYPE"
    if [ "$DIRTY_BUILD" = "yes" ]; then
        mka installclean
    fi
    mka bacon -j6

    # Upload build + extras
    upload_assets "$DEVICE"

    # Output OTA JSON
    los_ota_json "$DEVICE"

    echo -e "\n\nDone!"
}
