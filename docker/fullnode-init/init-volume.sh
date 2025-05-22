#!/bin/bash
set -e

# Default to mainnet if not specified
NETWORK=${1:-mainnet}
echo "Initializing volume for Aptos $NETWORK..."

# Create necessary directories
mkdir -p /opt/aptos/data
mkdir -p /opt/aptos/etc

# Download network-specific files
echo "Downloading $NETWORK waypoint.txt..."
curl -s -o /opt/aptos/etc/waypoint.txt https://raw.githubusercontent.com/aptos-labs/aptos-networks/main/$NETWORK/waypoint.txt

echo "Downloading $NETWORK genesis.blob..."
curl -s -o /opt/aptos/etc/genesis.blob https://raw.githubusercontent.com/aptos-labs/aptos-networks/main/$NETWORK/genesis.blob

# Create fullnode.yaml configuration file
cat > /opt/aptos/etc/fullnode.yaml << EOF
base:
  role: "full_node"
  data_dir: "/opt/aptos/data"
  waypoint:
    from_file: "/opt/aptos/etc/waypoint.txt"
 
execution:
  genesis_file_location: "/opt/aptos/etc/genesis.blob"
 
full_node_networks:
  - network_id: "public"
    discovery_method: "onchain"
    listen_address: "/ip4/127.0.0.1/tcp/6182"
 
api:
  enabled: true
  address: "0.0.0.0:8080"
EOF

echo "Volume initialization complete for $NETWORK!"
echo "Files created:"
ls -la /opt/aptos/etc/
echo "Data directory:"
ls -la /opt/aptos/data/

# Ensure proper permissions
chmod -R 755 /opt/aptos

