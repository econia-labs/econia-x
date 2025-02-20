#!/bin/sh
# Loop over each Move.toml file passed per pre-commit filename batch, and
# format the given package directory. If any check fails, exit with error.
for manifest in "$@"; do
	aptos move fmt --package-path "$(dirname "$manifest")" || exit 1
done
