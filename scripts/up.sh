#!/bin/sh
set -eu

ignore_schema_update=false
case "${1:-}" in
	--no-check)
		if [ "$#" -ne 1 ]; then
			printf '%s\n' "Usage: $0 [--no-check]" >&2
			exit 2
		fi
		ignore_schema_update=true
		;;
	'')
		;;
	*)
		printf '%s\n' "Usage: $0 [--no-check]" >&2
		exit 2
		;;
esac

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

docker compose --profile schema-check build openldap schema-status
docker compose --profile schema-check up -d openldap

if docker compose --profile schema-check run --rm --no-deps schema-status; then
	exit 0
else
	status=$?
fi

if [ "$status" -eq 42 ]; then
	printf '%s\n' "SCHEMA_UPDATE_REQUIRED:" >&2
	printf '%s\n' "  Update: ./scripts/update-schema.sh" >&2
	printf '%s\n' "  Continue despite the mismatch: ./scripts/up.sh --no-check" >&2
	if [ "$ignore_schema_update" = true ]; then
		printf '%s\n' "Schema update ignored; OpenLDAP remains started." >&2
		exit 0
	fi
	exit 42
fi
exit "$status"
