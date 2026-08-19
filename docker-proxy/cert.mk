# cert — autorité locale et certificat servi par le proxy
# Logique : scripts/cert/*.sh

CERT_SCRIPTS := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/scripts

# Dossier des certificats (ignoré par git) et domaine de base couvert.
CERT_DIR ?= certs
DOMAIN   ?= localhost
export CERT_DIR DOMAIN

.PHONY: cert@install cert@sync cert@renew cert@status

cert@install:
	@$(CERT_SCRIPTS)/cert/install.sh

# À lancer après avoir démarré un nouveau projet : ajoute son hôte au
# certificat et recharge à chaud, sans redémarrer le proxy.
cert@sync:
	@$(CERT_SCRIPTS)/cert/sync.sh

cert@renew:
	@$(CERT_SCRIPTS)/cert/renew.sh

cert@status:
	@$(CERT_SCRIPTS)/cert/status.sh
