#!/usr/bin/env bash
# This script is meant to be run on Unix/Linux based systems

# start alice node
echo "*** Starting Alice node"

#get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# start node
$DIR/target/release/sentinel-chain \
  --base-path /tmp/alice \
  --chain=local \
  --alice \
  --rpc-port 9944 \
  --port 30333 \
  --node-key 0000000000000000000000000000000000000000000000000000000000000001 \
  --validator \
  --unsafe-rpc-external \
  --rpc-cors all
