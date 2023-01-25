#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

EXTRA_SEPOLICY_PATH := vendor/extra/sepolicy

# Common (legacy)
ifeq ($(TARGET_BOARD_PLATFORM), msm8953)
ifneq (,$(filter 20, $(PRODUCT_VERSION_MAJOR)))
BOARD_VENDOR_SEPOLICY_DIRS += \
    $(EXTRA_SEPOLICY_PATH)/vendor/common_legacy
endif

# Fm radio
BOARD_VENDOR_SEPOLICY_DIRS += \
    $(EXTRA_SEPOLICY_PATH)/vendor/fm

ifeq ($(PRODUCT_VERSION_MAJOR), 19)
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += \
    $(EXTRA_SEPOLICY_PATH)/private/fm
endif
endif
