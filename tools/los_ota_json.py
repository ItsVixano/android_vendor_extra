#!/usr/bin/python3
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

#
# Usage:
# ./los_ota_json.py
#

import os, hashlib, re, glob

rom_name = "lineage"
version = "19.1"


def getprop(prop):
    return re.search(r"(?<=" + prop + "=).*", open("system/build.prop").read()).group(0)


datetime = getprop("ro.build.date.utc")
filename = max(
    glob.glob(
        rom_name + "-" + version + "*" + getprop("ro.product.system.device") + ".zip"
    ),
    key=os.path.getctime,
)
id = hashlib.md5(open(filename, "rb").read()).hexdigest()
size = os.stat(filename).st_size

print(
    """
{
  "response": [
    {
      "datetime": %s,
      "filename": "%s",
      "id": "%s",
      "romtype": "unofficial",
      "size": %s,
      "url": " ",
      "version": "%s"
    }
  ]
}
"""
    % (datetime, filename, id, size, version)
)
