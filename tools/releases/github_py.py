#!/usr/bin/python3
#
# Copyright (C) 2024 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

import requests
import json
from config import GH_TOKEN


def create_git_release(GH_OWNER, GH_REPO, data):
    return requests.post(
        f"https://api.github.com/repos/{GH_OWNER}/{GH_REPO}/releases",
        headers={"Authorization": f"token {GH_TOKEN}"},
        data=json.dumps(data),
    )


def upload_asset(GH_OWNER, GH_REPO, release_id, asset, asset_data):
    return requests.post(
        f"https://uploads.github.com/repos/{GH_OWNER}/{GH_REPO}/releases/{release_id}/assets?name={asset}",
        headers={
            "Authorization": f"token {GH_TOKEN}",
            "Content-Type": "application/octet-stream",
        },
        data=asset_data,
    )
