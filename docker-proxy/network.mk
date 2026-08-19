# network — réseau Docker partagé entre le proxy et les projets
# Logique : scripts/network/*.sh

NETWORK_SCRIPTS := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/scripts

NETWORK ?= docker-proxy_proxy
export NETWORK

.PHONY: network@create

network@create:
	@$(NETWORK_SCRIPTS)/network/create.sh
