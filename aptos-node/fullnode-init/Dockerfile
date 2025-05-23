# cspell:word curlimages
FROM curlimages/curl:8.13.0

# Copy init script and fullnode config.
WORKDIR /app
COPY --chmod=755 init-volume.sh .
COPY fullnode.yaml .

WORKDIR /opt/aptos
ENTRYPOINT ["/app/init-volume.sh"]
