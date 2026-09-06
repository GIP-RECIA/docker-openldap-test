#!/bin/sh
set -eu

if [ -f .env ]; then
	set -a
	. ./.env
	set +a
fi

# docker compose parses every service, including schema-status, while stopping.
: "${SCHEMA_REFERENCE_DIR:=.}"
export SCHEMA_REFERENCE_DIR

docker compose down
