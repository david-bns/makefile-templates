#!/usr/bin/env bash
# make@stack — bascule le projet sur une autre stack (STACK)
#
# core accompagne toujours la stack dans le cône : c'est ce que cette commande
# épargne d'avoir à retenir.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

require_clone make@stack
require_stack make@stack

run git -C "$MAKE_DIR" sparse-checkout set "$STACK" "$CORE"
