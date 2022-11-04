#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit Android Go Makefile
$(call inherit-product, vendor/extra/product/go.mk)

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Overlays
PRODUCT_PACKAGES += \
    BromiteWebViewOverlay \
    LineageUpdaterOverlay

# ih8sn
ifneq ($(TARGET_BUILD_VARIANT), eng)
PRODUCT_PACKAGES += \
    ih8sn

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/external/ih8sn/system/etc/ih8sn.conf.$(subst lineage_,,$(TARGET_PRODUCT)):$(TARGET_COPY_OUT_SYSTEM)/etc/ih8sn.conf

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/ih8sn \
    system/etc/ih8sn.conf \
    system/etc/init/ih8sn.rc
endif

# Rootdir
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/init.debugrom.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/init.debugrom.rc
