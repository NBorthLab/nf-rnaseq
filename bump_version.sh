#!/usr/bin/env bash

set -eo pipefail

usage() {
    echo "$(basename "$0") <Version>"
}

version=$1

if [[ -z $version ]]; then
    echo "Missing version number."
    exit 1
fi

set -u

sed -i -E "/version/{ s/[0-9]+\.[0-9]+\.[0-9]+/$version/ }" ./nextflow.config

sed -i -E "/nextflow run .+ -r /{ s/[0-9]+\.[0-9]+\.[0-9]+/$version/ }" ./README.md

echo "Sucessfully bumped new version $version."
