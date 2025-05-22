#!/bin/sh
set -e

# Build and run the initialization container.
NETWORK="$1" docker compose up --build
