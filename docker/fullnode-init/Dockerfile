FROM debian:slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy initialization script and fullnode config
COPY init-volume.sh /app/
COPY fullnode.yaml /app/
RUN chmod +x /app/init-volume.sh

# Default to mainnet, can be overridden with --build-arg or at runtime
ARG NETWORK=mainnet
ENV NETWORK=$NETWORK

# Create directories that will be mounted
RUN mkdir -p /opt/aptos/data /opt/aptos/etc

ENTRYPOINT ["/app/init-volume.sh"]

