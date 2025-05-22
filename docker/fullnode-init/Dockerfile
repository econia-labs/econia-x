FROM debian:slim-bookworm-20230612

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates=20230311 \
    curl=7.88.1-10+deb12u4 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy initialization script and fullnode config
COPY init-volume.sh /app/
COPY fullnode.yaml /app/
RUN chmod +x /app/init-volume.sh

# Create directories that will be mounted
RUN mkdir -p /opt/aptos/data /opt/aptos/etc

ENTRYPOINT ["/app/init-volume.sh"]

