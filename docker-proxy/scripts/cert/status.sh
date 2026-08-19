#!/usr/bin/env bash
# cert@status — noms couverts, échéance, et état de la confiance
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

CERT="$CERT_DIR/$DOMAIN.pem"
[ -f "$CERT" ] || die "cert@status : aucun certificat dans « $CERT_DIR » — lancer « make cert@install »"

echo
printf '  \033[1mCertificat\033[0m\n'
openssl x509 -in "$CERT" -noout -ext subjectAltName | tail -1 | sed 's/^ */    /'
printf '    expire le : %s\n' "$(openssl x509 -in "$CERT" -noout -enddate | cut -d= -f2)"

DAYS=$(( ( $(date -d "$(openssl x509 -in "$CERT" -noout -enddate | cut -d= -f2)" +%s) - $(date +%s) ) / 86400 ))
if [ "$DAYS" -lt 30 ]; then warn "  expire dans $DAYS jours — lancer « make cert@renew »"
else printf '    reste %s jours\n' "$DAYS"; fi

printf '\n  \033[1mConfiance\033[0m\n'
if ls /usr/local/share/ca-certificates/ 2>/dev/null | grep -qi mkcert; then
  printf '    magasin système : \033[32mok\033[0m\n'
else warn "  magasin système : ABSENT — lancer « mkcert -install »"; fi
if certutil -d "sql:$HOME/.pki/nssdb" -L 2>/dev/null | grep -qi mkcert; then
  printf '    magasin NSS (navigateurs) : \033[32mok\033[0m\n'
else warn "  magasin NSS : ABSENT — installer libnss3-tools puis « mkcert -install »"; fi
echo
