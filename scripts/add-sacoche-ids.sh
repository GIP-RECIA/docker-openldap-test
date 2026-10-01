#!/bin/sh
set -eu

case "${1:-}" in
      '')
              printf '%s\n' "Usage: $0 <UAI>" >&2
              printf '%s\n' "Adds an ESCOPersonExternalIds: SACOCHE\$<uuid> line to every" >&2
              printf '%s\n' "person entry with the given ESCOUAI, in the bootstrap LDIF." >&2
              exit 2
              ;;
esac

uai="$1"
ldif_file=".docker/bootstrap/ldif/custom/31-people.ldif"

if [ ! -f "$ldif_file" ]; then
      printf '%s\n' "Error: $ldif_file not found (run this script from the repo root)" >&2
      exit 1
fi

if ! command -v uuidgen >/dev/null 2>&1; then
      printf '%s\n' "Error: uuidgen not found (install uuid-runtime)" >&2
      exit 1
fi

tmp_file="${ldif_file}.tmp"

awk -v uai="$uai" -f "$(dirname "$0")/awk/add-sacoche-ids.awk" "$ldif_file" > "$tmp_file"

mv "$tmp_file" "$ldif_file"