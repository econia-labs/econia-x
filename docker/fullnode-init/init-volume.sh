#!/bin/sh
set -e

# Validate network parameter
if [ -z "$1" ]; then
  echo "Error: Network parameter is required."
  echo "Usage: $0 <network>"
  echo "Supported networks: mainnet, testnet, devnet"
  exit 1
fi

NETWORK="$1"

# Validate network is one of the supported options
case "$NETWORK" in
  mainnet|testnet|devnet)
    echo "Initializing volume for Aptos $NETWORK..."
    ;;
  *)
    echo "Error: Invalid network '$NETWORK'."
    echo "Supported networks: mainnet, testnet, devnet"
    exit 1
    ;;
esac

# Base URL for Aptos network files
APTOS_NETWORKS_URL="https://raw.githubusercontent.com/aptos-labs/aptos-networks/main"

# Create necessary directories
mkdir -p /opt/aptos/data
mkdir -p /opt/aptos/etc

# Check if waypoint.txt already exists
if [ -f "/opt/aptos/etc/waypoint.txt" ]; then
  echo "waypoint.txt already exists, skipping download."
else
  echo "Downloading $NETWORK waypoint.txt..."
  curl -s -o /opt/aptos/etc/waypoint.txt \
    "$APTOS_NETWORKS_URL/$NETWORK/waypoint.txt"
fi

# Check if genesis.blob already exists
if [ -f "/opt/aptos/etc/genesis.blob" ]; then
  echo "genesis.blob already exists, skipping download."
else
  echo "Downloading $NETWORK genesis.blob..."
  curl -s -o /opt/aptos/etc/genesis.blob \
    "$APTOS_NETWORKS_URL/$NETWORK/genesis.blob"
fi

# Copy fullnode.yaml configuration file if it doesn't exist
if [ -f "/opt/aptos/etc/fullnode.yaml" ]; then
  echo "fullnode.yaml already exists, skipping copy."
else
  echo "Creating fullnode.yaml configuration file..."
  cp /app/fullnode.yaml /opt/aptos/etc/
fi

echo "Volume initialization complete for $NETWORK!"
echo "Files in /opt/aptos/etc:"
ls -la /opt/aptos/etc/

# Ensure proper permissions
chmod -R 755 /opt/aptos

