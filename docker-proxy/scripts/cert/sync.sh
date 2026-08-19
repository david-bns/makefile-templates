#!/usr/bin/env bash
# cert@sync — remet le certificat en phase avec les projets qui tournent
#
# OpenSSL refuse de faire correspondre un joker dont le parent tient en un seul
# label : « *.localhost » ne couvre donc PAS « demo.localhost ». Chaque hôte est
# nommé explicitement, et cette commande reconstruit la liste toute seule.
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

have mkcert || die "cert@sync : mkcert introuvable — voir « make app@install »"
[ -d "$CERT_DIR" ] || mkdir -p "$CERT_DIR"

mapfile -t HOSTS < <(discover_hosts)
[ "${#HOSTS[@]}" -gt 0 ] || die "cert@sync : aucun hôte à couvrir"

info "hôtes couverts : ${HOSTS[*]}"
run mkcert -cert-file "$CERT_DIR/$DOMAIN.pem" -key-file "$CERT_DIR/$DOMAIN-key.pem" "${HOSTS[@]}" >/dev/null 2>&1 \
  || die "cert@sync : mkcert a échoué"
chmod 600 "$CERT_DIR/$DOMAIN-key.pem"
reload_tls
ok "certificat réémis pour ${#HOSTS[@]} hôte(s)"
