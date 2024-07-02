#!/usr/bin/env bash
# This script is meant to be run on Unix/Linux based systems

# start alice node
echo "*** Starting bob node"

#get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# start node
$DIR/target/release/sentinel-chain \
  --base-path /tmp/bob \
  --bootnodes /ip4/127.0.0.1/tcp/30333/p2p/12D3KooWEyoppNCUx8Yx66oV9fJnriXwCcXwDDUA2kj6vnc6iDEp \
  --chain=local \
  --bob \
  --port 30334 \
  --rpc-port 9945 \
  --validator \
  --unsafe-rpc-external \
  --rpc-cors all 