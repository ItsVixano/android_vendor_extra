#!/usr/bin/python3
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

#
# Usage:
# ./los_ota_json.py zipname
#

import os, sys, hashlib, subprocess, glob

version = "19.1"
datetime = (
    subprocess.Popen(
        ["/bin/grep", "ro.build.date.utc", "system/build.prop"], stdout=subprocess.PIPE
    )
    .communicate()[0]
    .decode("utf-8")
    .strip()
    .replace("ro.build.date.utc=", "")
)
filename = max(
    glob.glob(
        os.getcwd()
        + "/lineage-"
        + version
        + "*"
        + os.path.basename(os.getcwd())
        + ".zip"
    ),
    key=os.path.getctime,
).replace(os.getcwd() + "/", "")
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
