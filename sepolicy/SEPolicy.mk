#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

EXTRA_SEPOLICY_PATH := vendor/extra/sepolicy

# Fm radio
ifeq ($(BOARD_HAVE_QCOM_FM), true)
BOARD_VENDOR_SEPOLICY_DIRS += \
    $(EXTRA_SEPOLICY_PATH)/fm/vendor

SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += \
    $(EXTRA_SEPOLICY_PATH)/fm/private
endif
