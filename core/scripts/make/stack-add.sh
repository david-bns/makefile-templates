#!/usr/bin/env bash
# make@stack-add — matérialise une stack de plus, sans retirer l'actuelle (STACK)
#
# Deux stacks côte à côte définissent les mêmes cibles : make avertit et garde
# la dernière incluse. À réserver au temps de les comparer.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

require_clone make@stack-add
require_stack make@stack-add

run git -C "$MAKE_DIR" sparse-checkout add "$STACK"
