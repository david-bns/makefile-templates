#!/usr/bin/env bash
# app@stop — arrête le proxy
#
# Le réseau et les certificats survivent : le prochain « app@start » ne demande
# aucune réinstallation. L'arrêt est délibéré, donc le proxy ne redémarrera pas
# tout seul au prochain redémarrage de la machine.
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

run $COMPOSE down
ok "proxy arrêté (réseau et certificats conservés)"
