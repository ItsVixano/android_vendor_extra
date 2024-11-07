#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit Android Go Makefile
$(call inherit-product, vendor/extra/config/go.mk)

# Inherit priv Makefile
$(call inherit-product-if-exists, vendor/extra/priv/product.mk)

# Inherit MiuiCamera Makefile
$(call inherit-product-if-exists, vendor/xiaomi/miuicamera-$(shell echo -n $(TARGET_PRODUCT) | sed -e 's/^[a-z]*_//g')/device.mk)

# Audio (Debugging)
PRODUCT_PACKAGES += \
    tinymix \
    tinyplay

# Boot animation
TARGET_BOOTANIMATION_HALF_RES := true

# Overlays
PRODUCT_PACKAGES += \
    FrameworksResOverlay \
    LineageUpdaterOverlay \
    RippleSystemUIOverlay \
    SimpleDeviceConfigOverlay

# RemovePackages
PRODUCT_PACKAGES += \
    RemovePackages

# Rootdir
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/init.safailnet.rc:$(TARGET_COPY_OUT_PRODUCT)/etc/init/init.safailnet.rc

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/bin/neofetch:$(TARGET_COPY_OUT_SYSTEM)/bin/neofetch

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Spoof `dev-keys` builds into `release-keys`
ifneq ($(DEFAULT_SYSTEM_DEV_CERTIFICATE),build/make/target/product/security/testkey)
ifeq ($(shell expr $(PRODUCT_VERSION_MAJOR) \< 22),1)
PRODUCT_BUILD_PROP_OVERRIDES += \
    BUILD_VERSION_TAGS="release-keys" \
    BUILD_DISPLAY_ID="$(BUILD_ID)"
endif
endif
