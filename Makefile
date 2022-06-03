args = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$a="$($a)"))

plugin_path = $(shell pwd)
plugin_in_docker = /usr/src/redmine/plugins/redmine_tracky
container_path = $(shell pwd)/.containers
redmine_in_docker = /usr/src/redmine

setup:
	PLUGIN_PATH=$(plugin_path) REDMINE_PATH=$(redmine_in_docker) docker-compose -f $(container_path)/docker-compose.yml up -d

rebuild:
	PLUGIN_PATH=$(plugin_path) REDMINE_PATH=$(redmine_in_docker) docker-compose -f $(container_path)/docker-compose.yml up -d --build

restart-s:
	PLUGIN_PATH=$(plugin_path) REDMINE_PATH=$(redmine_in_docker) docker-compose -f $(container_path)/docker-compose.yml kill redmine
	PLUGIN_PATH=$(plugin_path) REDMINE_PATH=$(redmine_in_docker) docker-compose -f $(container_path)/docker-compose.yml rm -f redmine
	make setup

db-setup:
	docker-compose -f $(container_path)/docker-compose.yml exec -T redmine bash -c "bundle exec rails db:prepare && bundle exec rake redmine:plugins:migrate"

clear:
	docker-compose exec -T redmine bash -c "Rails.cache.clear | bin/rails c"
