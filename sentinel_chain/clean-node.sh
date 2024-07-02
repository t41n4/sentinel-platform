#!/usr/bin/env bash
# This script is meant to be run on Unix/Linux based systems

# start alice node
echo "*** Starting bob node"

#get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# start node
$DIR/target/release/sentinel-chain purge-chain --base-path /tmp/alice --chain local -y
$DIR/target/release/sentinel-chain purge-chain --base-path /tmp/bob --chain local -y
$DIR/target/release/sentinel-chain purge-chain --base-path /tmp/charlie --chain local -y
$DIR/target/release/sentinel-chain purge-chain --base-path /tmp/ferdie --chain local -y