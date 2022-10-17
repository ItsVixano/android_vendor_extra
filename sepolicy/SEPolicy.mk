#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

EXTRA_SEPOLICY_PATH := vendor/extra/sepolicy

## Vendor ##

# Common
BOARD_VENDOR_SEPOLICY_DIRS += \
    $(EXTRA_SEPOLICY_PATH)/vendor/common

# Fm radio
ifeq ($(BOARD_HAVE_QCOM_FM), true)
BOARD_VENDOR_SEPOLICY_DIRS += \
    $(EXTRA_SEPOLICY_PATH)/vendor/fm
endif
