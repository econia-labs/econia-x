#!/bin/bash
set -e

# Default to mainnet if not specified
NETWORK=${1:-mainnet}
echo "Initializing volume for Aptos $NETWORK..."

# Build and run the initialization container
docker-compose build --build-arg NETWORK=$NETWORK
NETWORK=$NETWORK docker-compose up

echo "Volume initialization complete!"
echo "The Aptos fullnode data is now available in the Docker volume: aptos_${NETWORK}_data"
echo ""
echo "To verify the volume contents, run:"
echo "  docker run --rm -v aptos_${NETWORK}_data:/opt/aptos alpine ls -la /opt/aptos/etc"
echo ""
echo "To use this volume with an Aptos fullnode, mount it to your fullnode container at /opt/aptos"

