#!/bin/bash
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

for project_name in $(cd "$VENDOR_PATCHES_PATH"; echo */); do
    project_path="$(tr _ / <<<$project_name)"

    cd "$ANDROID_BUILD_TOP"/"$project_path"
    git am "$VENDOR_PATCHES_PATH"/"$project_name"/*.patch
    git am --abort &> /dev/null
done

# Return to source rootdir
croot
