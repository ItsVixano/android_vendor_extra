#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

VENDOR_EXTRA_PATH := vendor/extra

# Props
TARGET_VENDOR_PROP += $(VENDOR_EXTRA_PATH)/props/vendor.prop
TARGET_SYSTEM_EXT_PROP += $(VENDOR_EXTRA_PATH)/props/system_ext.prop
ifneq ($(filter msm8953 hi6250,$(TARGET_BOARD_PLATFORM)),)
TARGET_VENDOR_PROP += $(VENDOR_EXTRA_PATH)/props/go_vendor.prop
TARGET_SYSTEM_EXT_PROP += $(VENDOR_EXTRA_PATH)/props/go_system_ext.prop
endif
