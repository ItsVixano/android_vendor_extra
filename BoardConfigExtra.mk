#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

VENDOR_EXTRA_PATH := vendor/extra

# Props
TARGET_VENDOR_PROP += $(VENDOR_EXTRA_PATH)/props/vendor.prop
ifeq ($(TARGET_BOARD_PLATFORM), msm8953)
TARGET_VENDOR_PROP += $(VENDOR_EXTRA_PATH)/props/go_vendor.prop
endif
