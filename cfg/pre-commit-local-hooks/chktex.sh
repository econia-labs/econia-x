#!/bin/sh
# Loop through each tex file passed per pre-commit filename batch, and run
# chktex on each file. If any check fails, exit with error.
for filename in "$@"; do
	chktex "$filename" || exit 1
done
