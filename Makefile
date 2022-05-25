args = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$a="$($a)"))

plugin_path = $(shell pwd)
plugin_in_docker = /usr/src/redmine/plugins/redmine_tracky
container_path = $(shell pwd)/.containers
redmine_in_docker = /usr/src/redmine

setup:
	CONTAINER_ENV=development PLUGIN_PATH=$(plugin_path) REDMINE_PATH=$(redmine_in_docker) docker-compose -f $(container_path)/docker-compose.yml up -d

rebuild:
	CONTAINER_ENV=development PLUGIN_PATH=$(plugin_path) REDMINE_PATH=$(redmine_in_docker) docker-compose -f $(container_path)/docker-compose.yml build
	CONTAINER_ENV=development PLUGIN_PATH=$(plugin_path) REDMINE_PATH=$(redmine_in_docker) docker-compose -f $(container_path)/docker-compose.yml up -d

restart-s:
	CONTAINER_ENV=development PLUGIN_PATH=$(plugin_path) REDMINE_PATH=$(redmine_in_docker) docker-compose -f $(container_path)/docker-compose.yml exec -T redmine bash -c "bin/rails restart"


test: setup
	docker-compose -f $(container_path)/docker-compose.yml -f $(container_path)/docker-compose.test.yml exec -T redmine bash -c "cd $(plugin_in_docker) && RAILS_ENV=test bundle install && bundle exec rake test"

exec-plugin:
	docker-compose exec -T redmine bash -c "cd $(plugin_in_docker) && $(command)"

exec-redmine:
	docker-compose exec -T redmine bash -c "$(command)"
