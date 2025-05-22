FROM alpine:3.18

RUN apk add --no-cache bash curl

WORKDIR /app

# Copy initialization script
COPY init-volume.sh /app/
RUN chmod +x /app/init-volume.sh

# Default to mainnet, can be overridden with --build-arg or at runtime
ARG NETWORK=mainnet
ENV NETWORK=$NETWORK

# Create directories that will be mounted
RUN mkdir -p /opt/aptos/data /opt/aptos/etc

ENTRYPOINT ["/app/init-volume.sh"]
CMD ["$NETWORK"]

