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
los_changelog() {
    # Check is $1 is empty
    if [ -z "$1" ]; then
        echo -e "\nPlease mention the device codename first"
        return 0
    fi

    # Defs
    local DEVICE="$1"
    local datetime_utc=$(cat out/target/product/"$DEVICE"/system/build.prop | grep ro.build.date.utc=)
    local datetime=$(date -d @${datetime_utc#*=} +%Y%m%d)
    local changelog_path="$VENDOR_EXTRA_PATH"/tools/releases/LineageOS_"$DEVICE"/lineage-"$LOS_VERSION"
    local changelog=${changelog_path}/changelog_"$datetime".txt

    # Delete the changelog if it already exists
    mkdir -p ${changelog_path}
    rm -rf ${changelog}

    # Thanks to @ ArianK16a
    # Generate changelog for 7 days
    for i in $(seq 7);
    do
        after_date=`date --date="$i days ago" +%F`
        until_date=`date --date="$(expr ${i} - 1) days ago" +%F`
        echo "====================" >> ${changelog}
        echo "     $until_date    " >> ${changelog}
        echo "====================" >> ${changelog}
        while read path; do
            git_log=`git --git-dir ./${path}/.git log --after=$after_date --until=$until_date --format=tformat:"%h %s [%an]"`
            if [[ ! -z "${git_log}" ]]; then
                echo "* ${path}" >> ${changelog}
                echo "${git_log}" >> ${changelog}
                echo "" >> ${changelog}
            fi
        done < ./.repo/project.list
    done
}

upload_assets() {
    # Check is $1 is empty
    if [ -z "$1" ]; then
        echo -e "\nPlease mention the device codename first"
        return 0
    fi

    # Defs
    local DEVICE="$1"
    local datetime_utc=$(cat out/target/product/"$DEVICE"/system/build.prop | grep ro.build.date.utc=)
    local datetime=$(date -d @${datetime_utc#*=} +%Y%m%d)

    # Upload assets on github
    mkdir -p "$VENDOR_EXTRA_PATH"/tools/releases/assets
    rm -rf "$VENDOR_EXTRA_PATH"/tools/releases/assets/*
    cd out/target/product/"$DEVICE"/ &> /dev/null
    for file in lineage-*.zip recovery.img boot.img vendor_*.img obj/PACKAGING/target_files_intermediates/*/IMAGES/vendor_*.img dtbo.img; do
        cp ${file} "$VENDOR_EXTRA_PATH"/tools/releases/assets &> /dev/null
    done
    cd "$VENDOR_EXTRA_PATH"/tools/releases/
    ./releases.py "$DEVICE" "$datetime"

    # Return to the root dir
    croot

    # Generate changelog
    los_changelog "$DEVICE"

    # Generate the OTA Json
    cd out/target/product/"$DEVICE"/ &> /dev/null
    "$VENDOR_EXTRA_PATH"/tools/los_ota_json.py ${datetime}

    # Return to the root dir
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

    # Conditionally push the build to the public
    if [[ "$2" = "-r" || "$2" = "--release-build" ]]; then
        echo -e "\nWarning: Push the build to the public once is done\n"
        sed -i "s|draft=True|draft=False|g" "$ANDROID_BUILD_TOP"/vendor/extra/tools/releases/releases.py
        sed -i "s|grep untagged|grep {GH_TAG}|g" "$ANDROID_BUILD_TOP"/vendor/extra/tools/releases/releases.py
        if cat "$ANDROID_BUILD_TOP"/vendor/extra/tools/los_ota_json.py | grep "os.system(\"git push github-local HEAD:main\")"; then
            echo "\n Git push patch already applied"
        else
            echo "os.system(\"git push github-local HEAD:main\")" >> "$ANDROID_BUILD_TOP"/vendor/extra/tools/los_ota_json.py
        fi
    else
        # Stash everything
        cd "$ANDROID_BUILD_TOP"/vendor/extra/
        git stash &> /dev/null
        cd "$ANDROID_BUILD_TOP"
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

    # goofy ahh build env
    if [[ $(hostname) == "phenix" ]]; then
        unset JAVAC
    fi

    croot
    sleep 3

    # Build
    lunch lineage_"$DEVICE"-"$BUILD_TYPE"
    if [ "$DIRTY_BUILD" = "yes" ]; then
        mka installclean
    fi

    mka bacon -j6

    # Upload build + extras + ota json + changelog
    upload_assets "$DEVICE" # ToDo: Skip if building on local

    # Clean out dir again for release builds
    if [[ "$2" = "-r" || "$2" = "--release-build" ]]; then
        mka installclean
    fi

    echo -e "\n\nDone!"
}

mka_kernel() {
    # Check is $1 is empty
    if [[ -z "$1" || "$1" = "-d" || "$1" = "--dirty" ]]; then
        echo -e "\nPlease mention the device to build first"
        return 0
    fi

    # Defs
    DEVICE="$1"
    BUILD_TYPE="userdebug" # ToDo: Don't hardcode it

    # goofy ahh build env
    if [[ $(hostname) == "phenix" ]]; then
        unset JAVAC
    fi

    # Stash everything
    cd "$ANDROID_BUILD_TOP"/vendor/extra/
    git stash &> /dev/null

    croot

    # Build
    lunch lineage_"$DEVICE"-"$BUILD_TYPE"
    mka installclean

    mka bootimage
    if [[ "$DEVICE" = "lisa" ]]; then
        if [[ "$LOS_VERSION" = "19" ]]; then
            mka dlkmimage
        else
            mka vendor_dlkmimage
        fi
        mka dtboimage
        mka vendorbootimage
    fi

    # Upload build + extras + ota json + changelog
    upload_assets "$DEVICE" # ToDo: Skip if building on local

    echo -e "\n\nDone!"
}
