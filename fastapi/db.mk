# db — base de données (FastAPI : migrations Alembic)
#
# Mêmes noms de cibles que la stack Laravel, implémentation différente :
# c'est tout l'intérêt de la convention.
# Logique : scripts/db/*.sh

DB_SCRIPTS := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/scripts

EXEC ?= docker compose exec -T api

# make db@rollback STEP=3   |   make db@migrate REVISION=<révision>
STEP     ?= 1
REVISION ?= head
export EXEC STEP REVISION

.PHONY: db@migrate db@rollback

db@migrate:
	@$(DB_SCRIPTS)/db/migrate.sh

db@rollback:
	@$(DB_SCRIPTS)/db/rollback.sh
