# make — le dépôt de commandes lui-même
#
# Domaine sans stack : ces commandes agissent sur le clone .make/, pas sur le
# projet. C'est ce qui vaut à « core » d'être toujours matérialisé, à côté de
# la stack : git -C .make sparse-checkout set <stack> core
# Logique : scripts/make/*.sh

MAKE_SCRIPTS := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/scripts

# Le clone piloté, et le dossier qui doit survivre à chaque bascule de stack.
MAKE_DIR ?= .make
CORE     ?= core

#   make make@stack STACK=fastapi
#   make make@push M="db@seed sur la stack laravel"
STACK ?=
M     ?=

# make@push ajoute le message au CHANGELOG. CHANGELOG=no pour s'en passer.
CHANGELOG ?= yes
export MAKE_DIR CORE STACK M CHANGELOG

.PHONY: make@update make@stack make@stack-add make@status make@push

make@update:
	@$(MAKE_SCRIPTS)/make/update.sh

make@stack:
	@$(MAKE_SCRIPTS)/make/stack.sh

make@stack-add:
	@$(MAKE_SCRIPTS)/make/stack-add.sh

make@status:
	@$(MAKE_SCRIPTS)/make/status.sh

make@push:
	@$(MAKE_SCRIPTS)/make/push.sh
