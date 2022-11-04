#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

VENDOR_EXTRA_PATH := vendor/extra

# Props
TARGET_SYSTEM_PROP += $(VENDOR_EXTRA_PATH)/props/system.prop
ifeq ($(TARGET_BOARD_PLATFORM), msm8953)
TARGET_SYSTEM_PROP += $(VENDOR_EXTRA_PATH)/props/go_system.prop
endif

# SEPolicy
include vendor/extra/sepolicy/SEPolicy.mk
