#!/bin/sh

# Exit on first error.
set -e

# Loop through each tex file passed per pre-commit filename batch.
for filename in "$@"; do
	# lacheck requires being run from the same directory as the file to
	# properly handle relative paths in \input and \include commands. Change to
	# the file's directory before running lacheck.
	cd "$(dirname "$filename")"
	# Run lacheck and filter its output. The `|| true`` prevents grep from
	# causing script failure when no lines match the patterns (which is the
	# success case).
	output=$(lacheck "$(basename "$filename")" |
		# Skip lacheck file processing notifications (lines starting with **).
		grep -v "^\*\*" |
		# Ignore finicky warnings about @ in LaTeX macro names. For more, see
		# https://tex.stackexchange.com/a/155451.
		grep -v "Do not use @ in LaTeX macro names" || true)
	# If there's any output after filtering, lacheck found real issues.
	if [ -n "$output" ]; then
		echo "$output"
		exit 1
	fi
	# Return to the original directory for the next file. Suppress cd's output
	# with > /dev/null to keep the hook's output clean.
	cd - >/dev/null
done
