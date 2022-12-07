args = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$a="$($a)"))

plugin_path = $(shell pwd)
plugin_in_docker = /usr/src/redmine/plugins/redmine_tracky
container_path = $(shell pwd)/.containers
redmine_in_docker = /usr/src/redmine

setup:
	docker compose up -d
rebuild:
	docker compose up -d --build
seed:
	docker compose exec redmine rake db:seed
test:
	docker compose exec rake test
