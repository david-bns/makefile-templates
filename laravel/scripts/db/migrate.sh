#!/usr/bin/env bash
# db@migrate — applique les migrations en attente
#
# Ébauche : la commande annonce seulement son nom et les variables qu’elle reçoit.
set -euo pipefail

echo "db@migrate  EXEC=${EXEC:-}"
