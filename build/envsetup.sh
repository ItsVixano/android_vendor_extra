#!/bin/bash
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

. build/envsetup.sh

export VENDOR_PATCHES_PATH=$(gettop)/vendor/extra/build/patches
. "$VENDOR_PATCHES_PATH"/apply-patches.sh
