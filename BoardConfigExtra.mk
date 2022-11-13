#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

VENDOR_EXTRA_PATH := vendor/extra

# Props
TARGET_VENDOR_PROP += $(VENDOR_EXTRA_PATH)/props/vendor.prop
ifeq ($(TARGET_BOARD_PLATFORM), msm8953)
TARGET_VENDOR_PROP += $(VENDOR_EXTRA_PATH)/props/go_vendor.prop
endif

# SEPolicy
include vendor/extra/sepolicy/SEPolicy.mk

# Soong vars
include vendor/extra/config/BoardConfigExtraSoong.mk
