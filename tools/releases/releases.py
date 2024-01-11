#!/usr/bin/python3
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

import sys
import os
import hashlib
from dotenv import load_dotenv
from github import Github
from time import sleep

# Release build
is_release_build = os.environ.get("IS_RELEASE_BUILD", "False").lower() == "true"

# Pre-checks
if len(sys.argv) < 3:
    print(
        "\nPlease mention for which device you want to create the releaase\n\n    ex: ./releases.py lisa 2022-07-05 20220713\n"
    )
    exit()

try:
    if len(os.listdir("assets")) == 0:
        print(
            "\nPlease make sure to create a folder named `assets` with all the assets you want to upload inside it\n"
        )
        exit()
except FileNotFoundError:
    # Print out the same error
    print(
        "\nPlease make sure to create a folder named `assets` with all the assets you want to upload inside it\n"
    )
    exit()


# defs
def get_device(var):
    return {
        # LineageOS 21.0
        "daisy": {1: "Mi A2 Lite", 2: "21.0", 3: "LineageOS_daisy"},
        "sakura": {1: "Redmi 6 Pro", 2: "21.0", 3: "LineageOS_sakura"},
        "lisa": {1: "Xiaomi 11 Lite 5G NE", 2: "21.0", 3: "LineageOS_lisa"},
        "miatoll": {1: "Xiaomi Atoll Family", 2: "21.0", 3: "LineageOS_miatoll"},
        "ysl": {1: "Redmi S2/Y2", 2: "21.0", 3: "LineageOS_ysl"},
        "xaga": {1: "POCO X4 GT", 2: "21.0", 3: "LineageOS_xaga"},
        # LineageOS 20.0
        "prague": {1: "Huawei P8 Lite 2017", 2: "20.0", 3: "LineageOS_prague"},
    }.get(var)


def sha1sum(var):
    file_hash = hashlib.sha1()
    BLOCK_SIZE = 15728640  # 15mb
    with open("assets/" + var, "rb") as f:
        fb = f.read(BLOCK_SIZE)
        while len(fb) > 0:
            file_hash.update(fb)
            fb = f.read(BLOCK_SIZE)

    return file_hash.hexdigest()


# Vars
load_dotenv()
GH_TOKEN = os.getenv("TOKEN")
GH_ASSETS = os.listdir("assets")
GH_OWNER = "ItsVixano-releases"  # Github profile name
GH_REPO = get_device(sys.argv[1])[3]  # Github repo name
GH_SECPATCH = sys.argv[2]  # LineageOS Security patch level
GH_TAG = sys.argv[3]  # Github release tag name
GH_LINEAGE = get_device(sys.argv[1])[2]  # LineageOS Release
GH_NAME = f"LineageOS {GH_LINEAGE} for {get_device(sys.argv[1])[1]} ({GH_TAG.replace('-', '')})"
GH_MESSAGE = f"""📅 Build date: `{GH_TAG}`

🔒 Security patches: `{GH_SECPATCH}`

📔 [Device Changelog](https://raw.githubusercontent.com/ItsVixano-releases/{GH_REPO}/main/lineage-{GH_LINEAGE[:-2]}/changelog_{GH_TAG.replace('-', '')}.txt)
📕 [Installation instructions](https://guide.itsvixano.me)

🔗 Sha1sums"""

# Calculate the sha1sums of the assets
for asset in GH_ASSETS:
    print(f"\nCalculating sha1sum for `{asset}`")
    GH_MESSAGE += f"\n`{sha1sum(asset)} {asset}`"

# Create release
print("\nCreating a release page ...")
repo = Github(GH_TOKEN).get_repo(GH_OWNER + "/" + GH_REPO)
release = repo.create_git_release(
    GH_TAG.replace("-", ""),  # tag
    GH_NAME,  # name
    GH_MESSAGE,  # message
    draft=not is_release_build,  # draft
)  # More info here https://pygithub.readthedocs.io/en/latest/github_objects/Repository.html?highlight=create_git_release#github.Repository.Repository.create_git_release

# Upload assets
print(
    "\nSleep for 3 seconds, this is required for refreshing git api in order to get the latest untagged tag avaible in the repo"
)
sleep(3)  # Sleep for 3 second
if is_release_build:
    grep_command = f"grep {GH_TAG.replace('-', '')}"
else:
    grep_command = "grep untagged"

GH_RELEASE_TAG = os.popen(
    f"curl -H 'Authorization: token {GH_TOKEN}' https://api.github.com/repos/{GH_OWNER}/{GH_REPO}/releases 2>&1 | {grep_command} | sed 's/.*\///' | sed 's|\",||'| head -1"
).read()
for asset in GH_ASSETS:
    print(f"\nUploading `{asset}`")
    repo.get_release(GH_RELEASE_TAG).upload_asset(f"assets/{asset}")

print(
    f"\nDone!\nYou can find the uploaded assets on https://github.com/{GH_OWNER}/{GH_REPO}/releases"
)
