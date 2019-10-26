#!/bin/sh
echo "Download BigWigsMods release.sh"
curl -o /tmp/BigWigsMods-release.sh https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh

echo "Packaging retail addon"
bash /tmp/BigWigsMods-release.sh

echo "Packaging classic addon"
bash /tmp/BigWigsMods-release.sh -g 1.13.2
