#!/usr/bin/env bash
# app@install — installe le proxy de zéro (idempotent)
set -euo pipefail
. "$(dirname "$0")/../lib.sh"
HERE="$(dirname "$0")/.."

printf '\n  \033[1mPrérequis\033[0m\n'
MISSING=0
check () { # $1=binaire  $2=paquet
  if have "$1"; then printf '    %-10s \033[32mok\033[0m\n' "$1"
  else printf '    %-10s \033[31mABSENT\033[0m — %s\n' "$1" "$2"; MISSING=1; fi
}
check docker  "voir https://docs.docker.com/engine/install/"
check mkcert  "sudo apt install mkcert"
check certutil "sudo apt install libnss3-tools  (sans lui, les navigateurs ne feront PAS confiance au certificat)"
docker compose version >/dev/null 2>&1 \
  && printf '    %-10s \033[32mok\033[0m\n' "compose" \
  || { printf '    %-10s \033[31mABSENT\033[0m — plugin docker compose\n' "compose"; MISSING=1; }
# On signale TOUS les manquants d'un coup, pas seulement le premier.
[ "$MISSING" -eq 0 ] || die $'\n  Installer les prérequis ci-dessus puis relancer « make app@install ».'

printf '\n  \033[1mRéseau\033[0m\n';      "$HERE/network/create.sh"
printf '\n  \033[1mCertificats\033[0m\n'; "$HERE/cert/install.sh"
printf '\n'; ok "installation terminée — « make app@start » pour démarrer"
