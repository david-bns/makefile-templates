#!/usr/bin/env bash
# app@restart — arrête puis redémarre le proxy
set -euo pipefail
. "$(dirname "$0")/../lib.sh"
HERE="$(dirname "$0")"
"$HERE/stop.sh"
"$HERE/start.sh"
