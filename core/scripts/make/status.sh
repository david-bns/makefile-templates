#!/usr/bin/env bash
# make@status — ce que le clone de commandes a de modifié
set -euo pipefail
. "$(dirname "$0")/lib.sh"

require_clone make@status

run git -C "$MAKE_DIR" status --short --branch
