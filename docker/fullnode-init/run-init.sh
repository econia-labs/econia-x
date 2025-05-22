#!/bin/sh
set -e

# Default to mainnet if not specified
NETWORK=${1:-mainnet}
echo "Initializing volume for Aptos $NETWORK..."

# Build and run the initialization container
docker-compose -f docker-compose.yaml build --build-arg NETWORK=$NETWORK
NETWORK=$NETWORK docker-compose -f docker-compose.yaml up

echo "Volume initialization complete!"
echo "The Aptos fullnode data is now available in the Docker volume: aptos_${NETWORK}_data"
echo ""
echo "To inspect the volume using Docker Desktop:"
echo "1. Open Docker Desktop"
echo "2. Go to the 'Volumes' tab"
echo "3. Find and click on 'aptos_${NETWORK}_data'"
echo "4. Browse the files in the volume"

