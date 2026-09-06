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
fetch_reference=true

if [ "${1:-}" = "--no-fetch" ]; then
	fetch_reference=false
	shift
fi
if [ "${1:-}" = "--ref" ] && [ -n "${2:-}" ]; then
	reference_ref=$2
	shift 2
fi
if [ "$#" -ne 0 ]; then
	printf '%s\n' "Usage: $0 [--no-fetch] [--ref <git-ref>]" >&2
	exit 2
fi

if [ -z "$reference_dir" ]; then
	printf '%s' "Schema reference repository path: " >&2
	read -r reference_dir
fi
if [ ! -d "$reference_dir/.git" ]; then
	printf '%s\n' "Schema reference repository not found: $reference_dir" >&2
	exit 2
fi
if [ "$fetch_reference" = true ]; then
	git -C "$reference_dir" fetch origin
fi

reference_commit=$(git -C "$reference_dir" rev-parse --verify "$reference_ref")
temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' EXIT
has_difference=0

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
	git -C "$reference_dir" show "$reference_commit:$reference_file" > "$temporary_dir/$reference_file"
	if ! diff -u ".docker/bootstrap/schema/$image_file" "$temporary_dir/$reference_file"; then
		has_difference=1
	fi
done

printf '%s\n' "Schema reference: $reference_commit ($reference_ref)"
if [ "$has_difference" -eq 1 ]; then
	printf '%s\n' "SCHEMA_UPDATE_REQUIRED: run ./scripts/update-schema.sh"
fi
exit "$has_difference"
