#
# Copyright (C) 2024 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SYSTEM_EXT_MODULE := true
LOCAL_CERTIFICATE := platform

LOCAL_SRC_FILES := $(call all-subdir-java-files)

LOCAL_RESOURCE_DIR := $(LOCAL_PATH)/$(PRODUCT_VERSION_MAJOR)/res

LOCAL_PACKAGE_NAME := LineageUpdaterOverlay
LOCAL_SDK_VERSION := current

include $(BUILD_RRO_PACKAGE)
