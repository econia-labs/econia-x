FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy init script and fullnode config.
COPY init-volume.sh /app/
COPY fullnode.yaml /app/
RUN chmod +x /app/init-volume.sh

ENTRYPOINT ["/app/init-volume.sh"]
