#!/bin/sh
set -eu

if [ -f .env ]; then
	provided_reference_dir=${SCHEMA_REFERENCE_DIR+x}
	provided_reference_ref=${SCHEMA_REFERENCE_REF+x}
	if [ "$provided_reference_dir" = x ]; then
		existing_reference_dir=$SCHEMA_REFERENCE_DIR
	fi
	if [ "$provided_reference_ref" = x ]; then
		existing_reference_ref=$SCHEMA_REFERENCE_REF
	fi
	set -a
	. ./.env
	set +a
	if [ "$provided_reference_dir" = x ]; then
		SCHEMA_REFERENCE_DIR=$existing_reference_dir
		export SCHEMA_REFERENCE_DIR
	fi
	if [ "$provided_reference_ref" = x ]; then
		SCHEMA_REFERENCE_REF=$existing_reference_ref
		export SCHEMA_REFERENCE_REF
	fi
fi

reference_dir=${SCHEMA_REFERENCE_DIR:-}
reference_ref=${SCHEMA_REFERENCE_REF:-origin/master}

if [ -z "$reference_dir" ]; then
	printf '%s' "Schema reference repository path: " >&2
	read -r reference_dir
fi
if [ ! -d "$reference_dir/.git" ]; then
	printf '%s\n' "Schema reference repository not found: $reference_dir" >&2
	exit 2
fi
export SCHEMA_REFERENCE_DIR="$reference_dir"

git -C "$reference_dir" fetch origin
reference_commit=$(git -C "$reference_dir" rev-parse --verify "$reference_ref")

if SCHEMA_REFERENCE_DIR="$reference_dir" SCHEMA_REFERENCE_REF="$reference_commit" ./scripts/check-schema-update.sh --no-fetch; then
	:
else
	check_status=$?
	if [ "$check_status" -ne 1 ]; then
		exit "$check_status"
	fi
fi

if [ "${1:-}" != "--yes" ]; then
	printf '%s\n' "This removes the OpenLDAP test data and configuration volumes."
	printf '%s\n' "Schema reference: $reference_commit"
	printf '%s' "Type yes to continue: "
	read -r confirmation
	if [ "$confirmation" != "yes" ]; then
		printf '%s\n' "Schema update cancelled."
		exit 1
	fi
fi

for mapping in \
	"ldappc.schema:05-ldappc.schema" \
	"esco-const.schema:11-esco-const.schema" \
	"esco-personne.schema:13-esco-personne.schema" \
	"esco-addons.schema:16-esco-addons.schema" \
	"esco-structure.schema:17-esco-structure.schema" \
	"esco-groupe.schema:21-esco-groupe.schema" \
	"esco-mail.schema:31-esco-mail.schema" \
	"esco-application.schema:51-esco-application.schema"; do
	reference_file=${mapping%%:*}
	image_file=${mapping#*:}
	git -C "$reference_dir" show "$reference_commit:$reference_file" > ".docker/bootstrap/schema/$image_file"
done

docker compose down -v
docker compose --profile schema-check build --no-cache
docker compose up -d openldap
docker compose --profile schema-check run --rm --no-deps schema-status
