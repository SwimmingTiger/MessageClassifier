#!/bin/sh
cd "$(dirname "$0")"

echo "Packaging addon for retail"
bash ./script/BigWigsMods-release.sh -g retail

echo "Packaging addon for classic 60"
bash ./script/BigWigsMods-release.sh -g classic

echo "Packaging addon for classic TBC"
bash ./script/BigWigsMods-release.sh -g bc
