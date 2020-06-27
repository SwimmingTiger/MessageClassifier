#!/bin/sh
cd "$(dirname "$0")"

echo "Packaging retail addon"
bash ./script/BigWigsMods-release.sh

echo "Packaging classic addon"
bash ./script/BigWigsMods-release.sh -g 1.13.4
