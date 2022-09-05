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

# Pre-checks
if len(sys.argv) < 3:
    print(
        "\nPlease mention for which device you want to create the releaase\n\n    ex: ./github_releases.py lisa 20220713\n"
    )
    exit()

try:
    if len(os.listdir("uploads")) == 0:
        print(
            "\nPlease make sure to create a folder named `uploads` with all the assets you want to upload inside it\n"
        )
        exit()
except FileNotFoundError:
    # Print out the same error
    print(
        "\nPlease make sure to create a folder named `uploads` with all the assets you want to upload inside it\n"
    )
    exit()

# defs
def get_device(var):
    return {
        "ysl": {1: "Redmi S2/Y2", 2: "19.1", 3: "LineageOS_ysl"},
        "daisy": {1: "Mi A2 Lite", 2: "19.1", 3: "LineageOS_daisy"},
        "lisa": {1: "Xiaomi 11 Lite 5g NE", 2: "19.1", 3: "LineageOS_lisa"},
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
GH_ASSETS = os.listdir("uploads")
GH_OWNER = "ItsVixano-releases"  # Github profile name
GH_REPO = get_device(sys.argv[1])[3]  # Github repo name
GH_TAG = sys.argv[2]  # Github release tag name
GH_NAME = f"LineageOS {get_device(sys.argv[1])[2]} for {get_device(sys.argv[1])[1]} ({GH_TAG})"
GH_MESSAGE = open(f"messages/{GH_REPO}.txt", "r").read()[:-1]

# Calculate the sha1sums of the assets
for asset in GH_ASSETS:
    print(f"\nCalculating sha1sum for `{asset}`")
    GH_MESSAGE += f"\n- {asset}: `{sha1sum(asset)}`"

# Create release
print("\nCreating a release page ...")
repo = Github(GH_TOKEN).get_repo(GH_OWNER + "/" + GH_REPO)
release = repo.create_git_release(
    GH_TAG,  # tag
    GH_NAME,  # name
    GH_MESSAGE,  # message
    draft=True,  # draft
)  # More info here https://pygithub.readthedocs.io/en/latest/github_objects/Repository.html?highlight=create_git_release#github.Repository.Repository.create_git_release

# Upload assets
print(
    "\nSleep for 3 seconds, this is required for refreshing git api in order to get the latest untagged tag avaible in the repo"
)
sleep(3)  # Sleep for 3 second
GH_RELEASE_TAG = os.popen(
    f"curl -H 'Authorization: token {GH_TOKEN}' https://api.github.com/repos/{GH_OWNER}/{GH_REPO}/releases 2>&1 | grep untagged | sed 's/.*\///' | sed 's|\",||'| head -1"
).read()
for asset in GH_ASSETS:
    print(f"\nUploading `{asset}`")
    repo.get_release(GH_RELEASE_TAG).upload_asset(f"uploads/{asset}")

print("\nDone!")
