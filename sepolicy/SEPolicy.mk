#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

EXTRA_SEPOLICY_PATH := vendor/extra/sepolicy

## Vendor ##

# Common
ifeq ($(PRODUCT_VERSION_MAJOR), 20)
BOARD_VENDOR_SEPOLICY_DIRS += \
    $(EXTRA_SEPOLICY_PATH)/vendor/common
endif

# Fm radio
ifeq ($(BOARD_HAVE_QCOM_FM), true)
BOARD_VENDOR_SEPOLICY_DIRS += \
    $(EXTRA_SEPOLICY_PATH)/vendor/fm

ifeq ($(PRODUCT_VERSION_MAJOR), 19)
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += \
    $(EXTRA_SEPOLICY_PATH)/private/fm
endif # ($(PRODUCT_VERSION_MAJOR), 19)

endif # ($(BOARD_HAVE_QCOM_FM), true)
