#!/usr/bin/env bash
# db@rollback — annule les derniers batchs de migrations (STEP)
#
# Ébauche : la commande annonce seulement son nom et les variables qu’elle reçoit.
set -euo pipefail

echo "db@rollback  EXEC=${EXEC:-}  STEP=${STEP:-}"
