#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit Android Go Makefile
$(call inherit-product, vendor/extra/config/go.mk)

# Inherit ih8sn Makefile
$(call inherit-product, vendor/extra/external/ih8sn/ih8sn.mk)

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Apps
ifeq ($(PRODUCT_VERSION_MAJOR), 19)
PRODUCT_PACKAGES += \
    GrapheneCamera
endif

# Rootdir
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/init.debugrom.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/init.debugrom.rc

# Overlays
PRODUCT_PACKAGES += \
    BromiteWebViewOverlay \
    LineageUpdaterOverlay$(PRODUCT_VERSION_MAJOR)

# LDAC
PRODUCT_PACKAGES += \
    libldacBT_enc \
    libldacBT_abr
