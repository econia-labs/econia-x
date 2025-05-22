FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy init script and fullnode config.
WORKDIR /app
COPY init-volume.sh .
COPY fullnode.yaml .
RUN chmod +x init-volume.sh

ENTRYPOINT ["/app/init-volume.sh"]
