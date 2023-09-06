#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit Android Go Makefile
$(call inherit-product, vendor/extra/config/go.mk)

# Inherit ih8sn Makefile
$(call inherit-product, vendor/extra/external/ih8sn/product.mk)

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Boot animation
TARGET_BOOTANIMATION_HALF_RES := true

# Rootdir
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/bin/neofetch:$(TARGET_COPY_OUT_SYSTEM)/bin/neofetch

# Overlays
PRODUCT_PACKAGES += \
    BromiteWebViewOverlay \
    LineageUpdaterOverlay$(PRODUCT_VERSION_MAJOR) \
    RippleSystemUIOverlay

# LDAC
PRODUCT_PACKAGES += \
    libldacBT_enc \
    libldacBT_abr
