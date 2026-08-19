#!/usr/bin/env bash
# network@create — crée le réseau partagé s'il n'existe pas (idempotent)
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

if docker network inspect "$NETWORK" >/dev/null 2>&1; then
  ok "réseau « $NETWORK » déjà présent — rien à faire"
else
  run docker network create "$NETWORK" >/dev/null
  ok "réseau « $NETWORK » créé"
fi
