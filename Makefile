# Date : 12/10/2021

# VARIABLES

DC=docker-compose

.DEFAULT_GOAL := help

.PHONY: help ## Generate list of targets with descriptions
help:
		@grep '##' Makefile \
		| grep -v 'grep\|sed' \
		| sed 's/^\.PHONY: \(.*\) ##[\s|\S]*\(.*\)/\1:\2/' \
		| sed 's/\(^##\)//' \
		| sed 's/\(##\)/\t/' \
		| expand -t14

##
## Project setup & day to day shortcuts
##---------------------------------------------------------------------------

# ENVIRONMENT SIDE

.PHONY: env ## Setup Docker & Symfony .env files
env:
	$(RUN) cp app/.env app/.env.local
	$(RUN) cp .env.example .env
	echo "Please fill environment files"

# CONTAINERS

.PHONY: php ## Run the php container
php:
	$(DC) exec php bash

.PHONY: nginx ## Run the php container
nginx:
	$(DC) exec nginx bash

# MANAGE CONTAINERS

.PHONY: start ## Start the project
setup-dev:
	$(DC) pull || true
	$(DC) build
	$(DC) up -d
	$(DC) exec php composer install
	sleep 5
	$(DC) exec php php bin/console doctrine:database:create --if-not-exists
	$(DC) exec php php bin/console doctrine:schema:update --force

.PHONY: restart ## Restart the project
restart-dev:
	$(DC) down
	make start

.PHONY: stop ## Stop the project
stop:
	$(DC) down


# PROJECT SIDE

# FIXTURES

.PHONY: fixtures ## Run the fixtures generator (-q = quiet)
fixtures:
	$(DC) exec php php bin/console hautelook:fixtures:load -q