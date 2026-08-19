#!/usr/bin/env bash
# app@logs — journaux du proxy (FOLLOW=no pour ne pas suivre)
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

if [ "${FOLLOW:-yes}" = no ]; then run $COMPOSE logs --tail 200
else run $COMPOSE logs -f --tail 50; fi
