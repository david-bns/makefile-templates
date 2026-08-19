#!/usr/bin/env bash
# app@status — état du conteneur, ports publiés, projets routés
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

docker info >/dev/null 2>&1 || die "app@status : Docker injoignable"

printf '\n  \033[1mProxy\033[0m\n'
STATE=$(docker ps -a --filter name=^traefik$ --format '{{.Status}}' 2>/dev/null || true)
if [ -z "$STATE" ]; then printf '    \033[33mnon créé\033[0m — « make app@start »\n'
else printf '    %s\n' "$STATE"
  docker ps --filter name=^traefik$ --format '{{.Ports}}' | tr ',' '\n' | sed 's/^ */    /'
fi

printf '\n  \033[1mProjets routés\033[0m\n'
FOUND=0
for c in $(docker ps -q); do
  NAME=$(docker inspect -f '{{.Name}}' "$c" | sed 's|^/||')
  [ "$NAME" = traefik ] && continue
  HOSTS=$(docker inspect -f '{{range $k,$v := .Config.Labels}}{{$v}}{{"\n"}}{{end}}' "$c" | { grep -oP 'Host\(`\K[^`]+' || true; } | tr '\n' ' ')
  [ -n "$HOSTS" ] || continue
  printf '    %-24s %s\n' "$NAME" "https://${HOSTS% }"; FOUND=1
done
[ "$FOUND" -eq 1 ] || printf '    \033[2maucun\033[0m\n'
printf '\n'
