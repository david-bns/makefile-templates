# app — cycle de vie applicatif (FastAPI)
# Logique : scripts/app/*.sh

APP_SCRIPTS := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/scripts

# Préfixe d'exécution, transmis aux scripts. Surchargeable depuis le Makefile
# du projet :
#   EXEC :=           exécution directe (venv activé)
#   EXEC := uv run    via uv
EXEC ?= docker compose exec -T api
export EXEC

.PHONY: app@install app@start app@stop

app@install:
	@$(APP_SCRIPTS)/app/install.sh

app@start:
	@$(APP_SCRIPTS)/app/start.sh

app@stop:
	@$(APP_SCRIPTS)/app/stop.sh
