#!/usr/bin/python3
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

import sys
import os
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


# Vars
load_dotenv()
GH_TOKEN = os.getenv("TOKEN")
GH_OWNER = sys.argv[1]  # Github profile name
GH_REPO = sys.argv[2]  # Github repo name
GH_TAG = sys.argv[3]  # Github release tag name
GH_BODY = open("release_body.txt", "r").read()
GH_NAME = f"LineageOS 19.1 for {get_device(GH_REPO)[1]} ({GH_TAG})"

# Create release
git = Github(GH_TOKEN)
repo = git.get_repo(GH_OWNER + "/" + GH_REPO)
repo.create_git_release(
    GH_TAG, GH_NAME, GH_BODY, True
)  # tag_name, release_name, release_body, draft

# Grab the output after wait
GH_DRAFT_TAG = input(
    f"Go on: https://github.com/{GH_OWNER}/{GH_REPO}/releases, Select the draft release and paste the release id here (it starts with 'untagged-')\n"
)

# Upload assets
assets = os.listdir("uploads")
for asset in assets:
    repo.get_release(GH_DRAFT_TAG).upload_asset(f"uploads/{asset}")
