#!/usr/bin/make

SHELL := /bin/bash # Use bash syntax

.PHONY: list init up app

list: ## Show available commands list
	@printf "\033[33m%s:\033[0m\n" 'Available commands'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize first time
	@sh ./bootstrap.sh

reinit: ## Re-initialize
	@docker-compose down
	@sh ./bootstrap.sh

up: ## Launch
	@docker-compose up -d --build

app: ## Shortcut to open app service container prompt
	@docker-compose exec app bash
