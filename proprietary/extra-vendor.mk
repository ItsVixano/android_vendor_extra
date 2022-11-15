#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# aptX
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/system_ext/lib64/libaptX_encoder.so:$(TARGET_COPY_OUT_SYSTEM_EXT)/lib64/libaptX_encoder.so \
    $(LOCAL_PATH)/system_ext/lib64/libaptXHD_encoder.so:$(TARGET_COPY_OUT_SYSTEM_EXT)/lib64/libaptXHD_encoder.so
