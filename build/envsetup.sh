#!/bin/bash
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

. build/envsetup.sh

export VENDOR_EXTRA_PATH=$(gettop)/vendor/extra/
export VENDOR_PATCHES_PATH="$VENDOR_EXTRA_PATH"/build/patches

. "$VENDOR_PATCHES_PATH"/apply-patches.sh

unset JAVAC

# functions
los_ota_json() {
    "$VENDOR_EXTRA_PATH"/tools/los_ota_json.py
}
