#!/usr/bin/python3
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

import sys
import os
from config import GH_TOKEN
from hashlib import md5
from re import search, sub
from glob import glob

# Release build
is_release_build = os.environ.get("IS_RELEASE_BUILD", "False").lower() == "true"


def getprop(prop):
    return search(
        r"".join(["(?<=", prop, "=).*"]), open("system/build.prop").read()
    ).group(0)


version, datetime, incremental, codename = (
    getprop("ro.lineage.build.version"),  # version
    getprop("ro.build.date.utc"),  # datetime
    getprop("ro.build.version.incremental"),  # incremental
    getprop("ro.lineage.device"),  # codename
)
filename = max(
    glob("".join(["lineage-", version, "*", ".zip"])),
    key=os.path.getctime,
)
id = md5(open(filename, "rb").read()).hexdigest()
size = os.stat(filename).st_size
url = "".join(
    [
        "https://github.com/ItsVixano-releases/LineageOS_",
        codename,
        "/releases/download/",
        sub("[^0-9]", "", incremental)[:-6],
        "/",
        filename,
    ]
)

# Write the ota json to every file presen
ota_path = f"../../../../vendor/extra/tools/releases/LineageOS_{codename}/lineage-{version[:-2]}/"
ota = f"""{{
  "response": [
    {{
      "datetime": {datetime},
      "filename": "{filename}",
      "id": "{id}",
      "romtype": "unofficial",
      "size": {size},
      "url": "{url}",
      "version": "{version}"
    }}
  ]
}}"""

for ota_json_file in glob(os.path.join(ota_path, "*.json")):
    ota_json = open(ota_json_file, "w")
    ota_json.write(ota)
    ota_json.close()

# Write a dummy ota
dummy_ota = """{
  "response": []
}"""
dummy_ota_json = open(ota_path + f"{incremental}.json", "w")
dummy_ota_json.write(dummy_ota)
dummy_ota_json.close()

# Commit everything
GH_DATE = sys.argv[1].replace("-", "")
os.chdir(ota_path)
os.system(
    f'git add . && git commit -m "LineageOS_{codename}: lineage-{version[:-2]}: {GH_DATE}" --no-gpg-sign'
)

if is_release_build:
    os.system(
        f"git push https://{GH_TOKEN}@github.com/ItsVixano-releases/LineageOS_{codename}.git HEAD:main"
    )
