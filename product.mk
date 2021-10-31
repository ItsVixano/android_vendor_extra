#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Overlays
PRODUCT_PACKAGES += \
    UpdaterOverlay

# Apps
PRODUCT_PACKAGES += \
    GrapheneCamera

# ih8sn
PRODUCT_PACKAGES += \
    ih8sn

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/etc/ih8sn.conf.$(subst lineage_,,$(TARGET_PRODUCT)):/system/etc/ih8sn.conf

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/ih8sn \
    system/etc/ih8sn.conf \
    system/etc/init/ih8sn.rc
