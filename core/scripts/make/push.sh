#!/usr/bin/env bash
# make@push — renvoie les modifications au dépôt de templates (M)
#
# Le message sert deux fois : message de commit, et entrée de changelog datée
# du jour. CHANGELOG=no saute la seconde.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

require_clone make@push

[ -n "${M:-}" ] \
  || die 'make@push : préciser le message — make make@push M="db@seed sur la stack laravel"'

if [ -z "$(git -C "$MAKE_DIR" status --porcelain)" ]; then
  echo "make@push : rien à envoyer, le clone est propre"
  exit 0
fi

changelog () {
  local file="$MAKE_DIR/CHANGELOG.md" entry="- $(date +%F)  $M"

  [ -f "$file" ] || { echo "make@push : pas de CHANGELOG.md, entrée non écrite" >&2; return 0; }
  grep -q '^## Non publié$' "$file" \
    || { echo "make@push : pas de section « Non publié » dans CHANGELOG.md, entrée non écrite" >&2; return 0; }

  # Insère sous le titre de section, la plus récente en tête.
  awk -v e="$entry" '
    {
      if (attente) {
        if ($0 ~ /^[[:space:]]*$/) { print; print e; attente = 0; next }
        print ""; print e; attente = 0
      }
      print
      if ($0 ~ /^## Non publié[[:space:]]*$/) attente = 1
    }
    END { if (attente) { print ""; print e } }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

  printf '  \033[2m%s\033[0m\n' "CHANGELOG.md ← $entry"
}

[ "${CHANGELOG:-yes}" = no ] || changelog

run git -C "$MAKE_DIR" add -A
run git -C "$MAKE_DIR" commit -m "$M"
run git -C "$MAKE_DIR" push
