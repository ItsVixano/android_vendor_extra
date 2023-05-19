#!/bin/bash
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

# Defs
LOS_VERSION=$(grep "PRODUCT_VERSION_MAJOR" "${ANDROID_BUILD_TOP}"/vendor/lineage/config/version.mk | sed 's/PRODUCT_VERSION_MAJOR = //g' | head -1)
VENDOR_EXTRA_PATH=$(gettop)/vendor/extra
VENDOR_PATCHES_PATH="${VENDOR_EXTRA_PATH}"/build/patches
VENDOR_PATCHES_PATH_VERSION="${VENDOR_PATCHES_PATH}"/lineage-"${LOS_VERSION}"

# Logging defs
LOGI() {
    echo -e "\n\033[32m[INFO]: $1\033[0m\n"
}

LOGW() {
    echo -e "\n\033[33m[WARNING]: $1\033[0m\n"
}

LOGE() {
    echo -e "\n\033[31m[ERROR]: $1\033[0m\n"
}

# Apply patches
if [[ "${APPLY_PATCHES}" == "true" ]]; then
    LOGI "Applying Patches"

    for project_name in $(cd "${VENDOR_PATCHES_PATH_VERSION}"; echo */); do
        project_path="$(tr _ / <<<$project_name)"

        cd "${ANDROID_BUILD_TOP}"/${project_path}
        git am "${VENDOR_PATCHES_PATH_VERSION}"/${project_name}/*.patch
        git am --abort &> /dev/null
    done

    # Return to source rootdir
    croot
fi

# functions
los_changelog() {
    # Defs
    local changelog_path="${VENDOR_EXTRA_PATH}"/tools/releases/LineageOS_"${DEVICE}"/lineage-"${LOS_VERSION}"
    local changelog=${changelog_path}/changelog_${datetime}.txt
    local datetime_utc=$(cat out/target/product/"${DEVICE}"/system/build.prop | grep ro.build.date.utc=)
    local datetime=$(date -d @${datetime_utc#*=} +%Y%m%d)

    if [[ -z "${DEVICE}" ]]; then
        LOGE "Please define \${DEVICE} value"
        return 0
    fi

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
    # Defs
    local datetime_utc=$(cat out/target/product/"${DEVICE}"/system/build.prop | grep ro.build.date.utc=)
    local datetime=$(date -d @${datetime_utc#*=} +%Y%m%d)

    if [[ -z "${DEVICE}" ]]; then
        LOGE "Please define \${DEVICE} value"
        return 0
    fi

    # Upload assets on github
    mkdir -p "${VENDOR_EXTRA_PATH}"/tools/releases/assets
    rm -rf "${VENDOR_EXTRA_PATH}"/tools/releases/assets/*
    cd out/target/product/"${DEVICE}"/ &> /dev/null
    for file in lineage-*.zip recovery.img boot.img vendor_*.img obj/PACKAGING/target_files_intermediates/*/IMAGES/vendor_*.img dtbo.img; do
        cp ${file} "${VENDOR_EXTRA_PATH}"/tools/releases/assets &> /dev/null
    done
    cd "${VENDOR_EXTRA_PATH}"/tools/releases/
    ./releases.py "${DEVICE}" ${datetime}

    # Return to the root dir
    croot

    # Generate changelog
    los_changelog

    # Generate the OTA Json
    cd out/target/product/"${DEVICE}"/ &> /dev/null
    "${VENDOR_EXTRA_PATH}"/tools/los_ota_json.py ${datetime}

    # Return to the root dir
    croot
}

mka_build() {
    # Defs
    DEVICE=""
    local RELEASE_BUILD="false"
    local DIRTY_BUILD="false"
    local BUILD_TYPE="userdebug"
    local LOCAL_BUILD="false"

    while [ "$#" -gt 0 ]; do
        case "${1}" in
            --device)
                    DEVICE="${2}"
                    ;;
            -r|--release-build)
                    local RELEASE_BUILD="true"
                    ;;
            -d|--dirty)
                    local DIRTY_BUILD="true"
                    ;;
            --build-type)
                    local BUILD_TYPE="${2}"
                    ;;
            -l|--local-build)
                    local LOCAL_BUILD="true"
                    ;;
        esac
        shift
    done

    if [[ -z "${DEVICE}" ]]; then
        LOGE "Please define --device value"
        return 0
    fi

    # Conditionally push the build to the public
    if [[ "${RELEASE_BUILD}" = "true" ]]; then
        LOGW "Pushing the build to the public once is done"
        sed -i "s|is_release_build = False|is_release_build = True|g" "$VENDOR_EXTRA_PATH"/tools/releases/releases.py
        sed -i "s|is_release_build = False|is_release_build = True|g" "$VENDOR_EXTRA_PATH"/tools/los_ota_json.py
    else
        sed -i "s|is_release_build = True|is_release_build = False|g" "$VENDOR_EXTRA_PATH"/tools/los_ota_json.py
        sed -i "s|is_release_build = True|is_release_build = False|g" "$VENDOR_EXTRA_PATH"/tools/releases/releases.py
    fi

    # goofy ahh build env
    if [[ $(hostname) == "phenix" ]]; then
        unset JAVAC
    fi

    croot
    sleep 3

    # Build
    rm -rf out/target/product/"${DEVICE}"/lineage-*.zip &> /dev/null
    lunch lineage_"${DEVICE}"-"${BUILD_TYPE}"
    if [[ "${DIRTY_BUILD}" != "true" ]]; then
        LOGI "Running installclean before compiling"
        mka installclean
    fi

    mka bacon -j6
    result=$?

    case ${result} in
        0)
            LOGI "Build completed!"
            ;;
        *)
            LOGE "Build failed!"
            return 0
            ;;
    esac

    if [[ "${LOCAL_BUILD}" != "true" ]]; then
        LOGI "Uploading the builds to the internet :D"
        upload_assets
    fi

    LOGI "Done!"
}