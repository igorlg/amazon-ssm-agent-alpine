#!/bin/bash

set -e -o pipefail

SUMFILE="SSM-VERSIONS"
TMPLFILE="APKBUILD.template"

VER="$1"
SUM="$(grep $VER $SUMFILE | awk '{print $2}')"

echo "Building version: $VER checksum: $SUM"

sed -e "s/SED_PKGVER/$VER/g -e "s/SED_PKGSUM/$SUM/g" $TMPLFILE > APKBUILD

