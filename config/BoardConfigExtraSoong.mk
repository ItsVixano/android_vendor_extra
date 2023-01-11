#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

# Setup SOONG_CONFIG_* vars to export the vars listed above.
# Documentation here:
# https://github.com/LineageOS/android_build_soong/commit/8328367c44085b948c003116c0ed74a047237a69

SOONG_CONFIG_lineageQcomVars += \
    qcom_no_fm_firmware \

# Soong value variables
SOONG_CONFIG_lineageQcomVars_qcom_no_fm_firmware := $(TARGET_QCOM_NO_FM_FIRMWARE)
