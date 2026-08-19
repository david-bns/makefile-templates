# Commun aux scripts du domaine make. Sourcé, jamais exécuté.
#
# Ces commandes agissent sur le clone .make/, pas sur le projet : elles sont
# donc les seules à ne pas passer par EXEC.

MAKE_DIR="${MAKE_DIR:-.make}"
CORE="${CORE:-core}"

die () { printf '%s\n' "$*" >&2; exit 1; }

# Affiche la commande avant de la lancer : ce qui est fait au clone reste lisible,
# et recopiable tel quel — d'où les guillemets rendus aux arguments qui en ont.
run () {
  local arg shown=()
  for arg in "$@"; do
    case $arg in *[[:space:]]*) shown+=("\"$arg\"") ;; *) shown+=("$arg") ;; esac
  done
  printf '  \033[2m%s\033[0m\n' "${shown[*]}"
  "$@"
}

require_clone () {
  git -C "$MAKE_DIR" rev-parse --git-dir >/dev/null 2>&1 \
    || die "$1 : « $MAKE_DIR » n'est pas un clone git — voir « Brancher le dépôt » dans le README"
}

# Les dossiers de premier niveau du dépôt, moins core : les stacks disponibles,
# qu'elles soient matérialisées ou non.
stacks () {
  git -C "$MAKE_DIR" ls-tree -d --name-only HEAD | grep -vFx "$CORE"
}

require_stack () {
  [ -n "${STACK:-}" ] \
    || die "$1 : préciser la stack — make $1 STACK=<stack> (disponibles : $(stacks | tr '\n' ' '))"
  stacks | grep -qFx "$STACK" \
    || die "$1 : stack « $STACK » inconnue du dépôt (disponibles : $(stacks | tr '\n' ' '))"
}
