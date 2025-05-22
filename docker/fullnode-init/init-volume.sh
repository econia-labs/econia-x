#!/bin/sh
set -e

# Validate network parameter.
if [ -z "$1" ]; then
	echo "Error: Network parameter is required."
	echo "Usage: $0 <network>"
	echo "Supported networks: mainnet, testnet, devnet"
	exit 1
fi
NETWORK="$1"
case "$NETWORK" in
mainnet | testnet | devnet)
	echo "Initializing volume for Aptos $NETWORK..."
	;;
*)
	echo "Error: Invalid network '$NETWORK'."
	echo "Supported networks: mainnet, testnet, devnet"
	exit 1
	;;
esac

# If there is no data directory, create it.
if [ ! -d "data" ]; then
	echo "Creating data directory..."
	mkdir -p data
fi

# Copy fullnode config file from /app/fullnode.yaml if it doesn't exist.
if [ -f "fullnode.yaml" ]; then
	echo "fullnode.yaml already exists, skipping copy."
else
	echo "Copying fullnode.yaml..."
	cp /app/fullnode.yaml .
fi

# Download waypoint and genesis files if they aren't present.
BASE_URL="https://raw.githubusercontent.com/aptos-labs/aptos-networks/main"
if [ -f "genesis.blob" ]; then
	echo "genesis.blob already exists, skipping download."
else
	echo "Downloading $NETWORK genesis.blob..."
	curl -O "$BASE_URL/$NETWORK/genesis.blob"
fi
if [ -f "waypoint.txt" ]; then
	echo "waypoint.txt already exists, skipping download."
else
	echo "Downloading $NETWORK waypoint.txt..."
	curl -O "$BASE_URL/$NETWORK/waypoint.txt"
fi
