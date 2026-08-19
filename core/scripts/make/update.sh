#!/usr/bin/env bash
# make@update — met à jour le dépôt de commandes
set -euo pipefail
. "$(dirname "$0")/lib.sh"

require_clone make@update

run git -C "$MAKE_DIR" pull --rebase
