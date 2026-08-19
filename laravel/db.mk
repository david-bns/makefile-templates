# db — base de données (Laravel : migrations Eloquent)
# Logique : scripts/db/*.sh

DB_SCRIPTS := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/scripts

EXEC ?= docker compose exec -T app

# Nombre de batchs annulés par db@rollback :  make db@rollback STEP=3
STEP ?= 1
export EXEC STEP

.PHONY: db@migrate db@rollback

db@migrate:
	@$(DB_SCRIPTS)/db/migrate.sh

db@rollback:
	@$(DB_SCRIPTS)/db/rollback.sh
