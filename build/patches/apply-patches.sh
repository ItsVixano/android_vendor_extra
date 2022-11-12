#!/bin/bash
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

LOS_VERSION=$(grep "PRODUCT_VERSION_MAJOR" "$ANDROID_BUILD_TOP"/vendor/lineage/config/version.mk | sed 's/PRODUCT_VERSION_MAJOR = //g' | head -1)
VENDOR_PATCHES_PATH_VERSION="$VENDOR_PATCHES_PATH"/lineage"$LOS_VERSION"

for project_name in $(cd "$VENDOR_PATCHES_PATH_VERSION"; echo */); do
    project_path="$(tr _ / <<<$project_name)"

    cd "$ANDROID_BUILD_TOP"/"$project_path"
    git am "$VENDOR_PATCHES_PATH_VERSION"/"$project_name"/*.patch
    git am --abort &> /dev/null
done

# Return to source rootdir
croot
