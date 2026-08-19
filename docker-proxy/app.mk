# app — cycle de vie du proxy (docker-proxy)
# Logique : scripts/app/*.sh

APP_SCRIPTS := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/scripts

# Pas d'EXEC dans cette stack : ces commandes agissent sur l'hôte (docker
# compose, docker network, mkcert) et non dans un conteneur — comme le domaine
# « make » de core/.
COMPOSE ?= docker compose
NETWORK ?= docker-proxy_proxy
DOMAIN  ?= localhost

# make app@logs FOLLOW=no  pour un vidage ponctuel au lieu d'un suivi
FOLLOW ?= yes
export COMPOSE NETWORK DOMAIN FOLLOW

.PHONY: app@install app@start app@stop app@restart app@status app@logs

app@install:
	@$(APP_SCRIPTS)/app/install.sh

app@start:
	@$(APP_SCRIPTS)/app/start.sh

app@stop:
	@$(APP_SCRIPTS)/app/stop.sh

app@restart:
	@$(APP_SCRIPTS)/app/restart.sh

app@status:
	@$(APP_SCRIPTS)/app/status.sh

app@logs:
	@$(APP_SCRIPTS)/app/logs.sh
