#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

VENDOR_EXTRA_PATH := vendor/extra

# Props
TARGET_VENDOR_PROP += $(VENDOR_EXTRA_PATH)/props/vendor.prop

# SEPolicy
include vendor/extra/sepolicy/SEPolicy.mk
