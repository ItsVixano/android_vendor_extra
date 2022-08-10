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

# Pre-checks
if len(sys.argv) < 4:
    print(
        """
Please mention in which repo you want to create the releaase

    ex: ./github_releases.py ItsVixano-releases LineageOS_lisa 20220713
"""
    )
    exit()

# defs
def get_device(var):
    return {
        "LineageOS_ysl": {1: "Redmi S2/Y2"},
        "LineageOS_daisy": {1: "Mi A2 Lite"},
        "LineageOS_lisa": {1: "Xiaomi 11 Lite 5g NE"},
    }.get(var)


def sha1sum(var):
    file_hash = hashlib.sha1()
    BLOCK_SIZE = 15728640  # 15mb
    with open("uploads/" + var, "rb") as f:
        fb = f.read(BLOCK_SIZE)
        while len(fb) > 0:
            file_hash.update(fb)
            fb = f.read(BLOCK_SIZE)

    return file_hash.hexdigest()


# Vars
load_dotenv()
GH_TOKEN = os.getenv("TOKEN")
GH_OWNER = sys.argv[1]  # Github profile name
GH_REPO = sys.argv[2]  # Github repo name
GH_TAG = sys.argv[3]  # Github release tag name
GH_BODY = open("release_body.txt", "r").read()
GH_NAME = f"LineageOS 19.1 for {get_device(GH_REPO)[1]} ({GH_TAG})"

# Calculate the sha1sums of the assets
assets = os.listdir("uploads")
first_line = True
for asset in assets:
    print(f"\nCalculating sha1sum for `{asset}`")
    if first_line == True:
        GH_BODY += f"- {asset}: `{sha1sum(asset)}`"
        first_line = False
    else:
        GH_BODY += f"\n- {asset}: `{sha1sum(asset)}`"

# Create release
git = Github(GH_TOKEN)
repo = git.get_repo(GH_OWNER + "/" + GH_REPO)
repo.create_git_release(
    GH_TAG, GH_NAME, GH_BODY, True
)  # tag_name, release_name, release_body, draft

# Grab the output after wait
GH_DRAFT_TAG = input(
    f"\nGo on https://github.com/{GH_OWNER}/{GH_REPO}/releases, Select the draft release and paste the release id from the url (it starts with `untagged-`)\n"
)

# Upload assets
for asset in assets:
    print(f"\nUploading `{asset}`")
    repo.get_release(GH_DRAFT_TAG).upload_asset(f"uploads/{asset}")

print("\nDone!")
