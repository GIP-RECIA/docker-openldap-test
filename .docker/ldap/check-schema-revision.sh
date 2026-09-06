#!/bin/sh
set -eu

source_schema_dir=/container/service/slapd/assets/config/bootstrap/schema
reference_schema_dir=/schema-reference

if [ ! -d "$reference_schema_dir" ]; then
	printf '%s\n' "OpenLDAP schema reference is unavailable."
	exit 1
fi

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
	if ! diff -q "$source_schema_dir/$image_file" "$reference_schema_dir/$reference_file" >/dev/null; then
		has_difference=1
	fi
done

if [ "$has_difference" -eq 0 ]; then
	printf '%s\n' "OpenLDAP schema is up to date."
	exit 0
fi

printf '%s\n' "OpenLDAP schema update is available."
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
diff -u "$source_schema_dir/$image_file" "$reference_schema_dir/$reference_file" || true
done
printf '%s\n' "SCHEMA_UPDATE_REQUIRED"
exit 42
