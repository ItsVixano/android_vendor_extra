#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

VENDOR_EXTRA_PATH := vendor/extra

# Camera
ifneq ($(filter atoll lahaina,$(TARGET_BOARD_PLATFORM)),)
TARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED := true
endif

# Camera - MiuiCamera
# To use with external/jemalloc_new from AOSPA
ifeq ($(TARGET_BOARD_PLATFORM), atoll)
MALLOC_SVELTE := true
MALLOC_SVELTE_FOR_LIBC32 := true
endif

# Props
TARGET_VENDOR_PROP += $(VENDOR_EXTRA_PATH)/props/vendor.prop
TARGET_SYSTEM_EXT_PROP += $(VENDOR_EXTRA_PATH)/props/system_ext.prop
ifneq ($(filter msm8953 hi6250,$(TARGET_BOARD_PLATFORM)),)
TARGET_VENDOR_PROP += $(VENDOR_EXTRA_PATH)/props/go_vendor.prop
TARGET_SYSTEM_EXT_PROP += $(VENDOR_EXTRA_PATH)/props/go_system_ext.prop
endif
