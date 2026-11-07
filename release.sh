#!/bin/sh
cd "$(dirname "$0")"

echo "Packaging addon"
bash ./script/BigWigsMods-release.sh
