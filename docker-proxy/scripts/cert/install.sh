#!/usr/bin/env bash
# cert@install — installe l'autorité locale dans les magasins, puis émet le certificat
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

have mkcert || die "cert@install : mkcert introuvable — « sudo apt install mkcert »"
# Sans certutil, « mkcert -install » réussit en sautant silencieusement Firefox
# et Chrome : le terminal serait content, les navigateurs afficheraient toujours
# un avertissement. On refuse donc d'avancer sans lui.
have certutil || die "cert@install : certutil introuvable — « sudo apt install libnss3-tools » (sinon les navigateurs ne feront PAS confiance au certificat)"

run mkcert -install
ls /usr/local/share/ca-certificates/ 2>/dev/null | grep -qi mkcert \
  || die "cert@install : l'autorité n'est pas dans le magasin système"
certutil -d "sql:$HOME/.pki/nssdb" -L 2>/dev/null | grep -qi mkcert \
  || warn "l'autorité n'apparaît pas dans le magasin NSS — redémarrer le navigateur puis vérifier « make cert@status »"
ok "autorité locale installée"

exec "$(dirname "$0")/sync.sh"
