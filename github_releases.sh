#!/bin/bash
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

# Example:
# Install github cli 'https://cli.github.com/'
# Follow https://cli.github.com/manual/ for login your gh acc 'Use ssh method instead of HTTPS'
# Place all your files inside 'uploads/'
# ./github_releases.sh user/repo tag

# Global vars
REPO=$1
TAG=$2
BODY=$(cat release.txt)
LOS='18.1'
DEVICE='Xiaomi 11 lite 5g NE'

# Create a release
gh api \
  --method POST \
  -H "Accept: application/vnd.github.v3+json" \
  /repos/"$REPO"/releases \
  -f tag_name="$TAG" \
  -f target_commitish='main' \
  -f name="LineageOS $LOS for $DEVICE ($TAG)" \
  -f body="$BODY" \
  -F draft=true \
  -F prerelease=false \
  -F generate_release_notes=false

# Upload files
gh release upload "$TAG" uploads/* --repo "$REPO"
