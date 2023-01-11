#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

# aptX - from cheetah-user-13-T1B3.221003.008-9245559-release-keys
# system_ext/lib64/libaptX_encoder.so|df1c89d7af1bb35808d5fe3496b04ba066c10cbc
# system_ext/lib64/libaptXHD_encoder.so|e13fa70c97caaa24d061678bdee608eb8850a69e
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/system_ext/lib64/libaptX_encoder.so:$(TARGET_COPY_OUT_SYSTEM_EXT)/lib64/libaptX_encoder.so \
    $(LOCAL_PATH)/system_ext/lib64/libaptXHD_encoder.so:$(TARGET_COPY_OUT_SYSTEM_EXT)/lib64/libaptXHD_encoder.so
