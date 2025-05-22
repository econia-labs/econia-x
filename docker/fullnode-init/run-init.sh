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

# Build and run the initialization container
docker-compose -f docker-compose.yaml build
NETWORK=$NETWORK docker-compose -f docker-compose.yaml up

echo "Volume initialization complete!"
echo "The Aptos fullnode data is now available in the Docker volume: ${NETWORK}_fullnode_data"
echo ""
echo "To inspect the volume using Docker Desktop:"
echo "1. Open Docker Desktop"
echo "2. Go to the 'Volumes' tab"
echo "3. Find and click on '${NETWORK}_fullnode_data'"
echo "4. Browse the files in the volume"

