#!/usr/bin/env bash
# app@start — démarre le proxy
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

docker network inspect "$NETWORK" >/dev/null 2>&1 \
  || die "app@start : réseau « $NETWORK » absent — lancer « make app@install »"
[ -f "$CERT_DIR/$DOMAIN.pem" ] \
  || die "app@start : aucun certificat — lancer « make app@install »"

run $COMPOSE up -d
ok "proxy démarré — tableau de bord : https://traefik.$DOMAIN"
