#!/usr/bin/env bash
# cert@renew — réémet le certificat depuis l'autorité locale existante
#
# L'ancre de confiance n'est pas touchée : aucun projet n'est à réintégrer et
# aucun navigateur n'est à reconfigurer.
set -euo pipefail
. "$(dirname "$0")/../lib.sh"
exec "$(dirname "$0")/sync.sh"
