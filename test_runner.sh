#/bin/bash
set -e

TESTSPACE=$HOME/testpace
PATH_TO_REDMINE=$TESTSPACE/redmine

cd $PATH_TO_REDMINE
bundle exec rails db:create
# run redmine database migrations
bundle exec rake db:migrate
# run plugin database migrations
bundle exec rake redmine:plugins:migrate
# install redmine database
#bundle exec rake redmine:load_default_data REDMINE_LANG=en
bundle exec rake db:structure:dump
cd $PATH_TO_REDMINE
# run tests
# bundle exec rake TEST=test/unit/role_test.rb
bundle exec rake redmine:plugins:test NAME=$NAME_OF_PLUGIN
