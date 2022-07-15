#!/usr/bin/python3
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

import os
from hashlib import md5
from re import search
from glob import glob


def getprop(prop):
    return search(
        r"".join(["(?<=", prop, "=).*"]), open("system/build.prop").read()
    ).group(0)


version, datetime, incremental = (
    getprop("ro.lineage.build.version"),  # version
    getprop("ro.build.date.utc"),  # datetime
    getprop("ro.build.version.incremental"),  # incremental
)
filename = max(
    glob("".join(["lineage-", version, "*", ".zip"])),
    key=os.path.getctime,
)
id = md5(open(filename, "rb").read()).hexdigest()
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

Place a dummy json file named "%s.json"
"""
    % (datetime, filename, id, size, version, incremental)
)
