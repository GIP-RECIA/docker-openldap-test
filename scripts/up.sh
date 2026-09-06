#!/bin/sh
set -eu

if [ -z "${SCHEMA_REFERENCE_DIR:-}" ] && [ -f .env ]; then
	set -a
	. ./.env
	set +a
fi

reference_dir=${SCHEMA_REFERENCE_DIR:-}

if [ -z "$reference_dir" ]; then
	printf '%s' "Schema reference repository path: " >&2
	read -r reference_dir
fi
if [ ! -d "$reference_dir/.git" ]; then
	printf '%s\n' "Schema reference repository not found: $reference_dir" >&2
	exit 2
fi
export SCHEMA_REFERENCE_DIR="$reference_dir"

docker compose --profile schema-check up -d --build openldap

if docker compose --profile schema-check run --rm --no-deps schema-status; then
	exit 0
else
	status=$?
fi

if [ "$status" -eq 42 ]; then
	exit 42
fi
exit "$status"
