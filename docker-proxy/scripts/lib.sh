# Commun aux domaines app, network et cert. Sourcé, jamais exécuté.
#
# Ces commandes agissent sur l'hôte (docker compose, docker network, mkcert) et
# non dans un conteneur : comme le domaine « make » de core/, elles ne passent
# donc pas par EXEC.

CERT_DIR="${CERT_DIR:-certs}"
NETWORK="${NETWORK:-docker-proxy_proxy}"
COMPOSE="${COMPOSE:-docker compose}"
DOMAIN="${DOMAIN:-localhost}"
TLS_FILE="traefik/dynamic/tls.yml"

die () { printf '%s\n' "$*" >&2; exit 1; }
info () { printf '  \033[2m%s\033[0m\n' "$*"; }
ok   () { printf '  \033[32m%s\033[0m\n' "$*"; }
warn () { printf '  \033[33m%s\033[0m\n' "$*" >&2; }

# Affiche la commande avant de la lancer, recopiable telle quelle.
run () {
  local arg shown=()
  for arg in "$@"; do
    case $arg in *[[:space:]]*) shown+=("\"$arg\"") ;; *) shown+=("$arg") ;; esac
  done
  printf '  \033[2m%s\033[0m\n' "${shown[*]}"
  "$@"
}

have () { command -v "$1" >/dev/null 2>&1; }

# Les hôtes à couvrir : localhost, le tableau de bord, et tout Host(`…`) déclaré
# par un conteneur en cours d'exécution. C'est ce qui évite d'avoir à nommer les
# projets à la main.
discover_hosts () {
  {
    printf '%s\n' "$DOMAIN" "traefik.$DOMAIN"
    docker ps -q 2>/dev/null | xargs -r docker inspect \
      --format '{{range $k, $v := .Config.Labels}}{{$v}}{{"\n"}}{{end}}' 2>/dev/null \
      | grep -oP 'Host\(`\K[^`]+' || true
  } | sort -u
}

# Recharge la configuration dynamique sans redémarrer le proxy : Traefik
# surveille le dossier, une modification de date suffit.
reload_tls () {
  [ -f "$TLS_FILE" ] || return 0
  touch "$TLS_FILE"
  info "rechargement à chaud déclenché ($TLS_FILE)"
}
