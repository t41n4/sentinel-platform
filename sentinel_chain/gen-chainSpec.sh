#!/usr/bin/env bash
# This script is meant to be run on Unix/Linux based systems

# start alice node
echo "*** Generating Chain Spec"

#get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# start node
$DIR/target/release/sentinel-chain build-spec --raw --chain local > localSpec.json
