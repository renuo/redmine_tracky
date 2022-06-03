#/bin/bash
set -e

TESTSPACE=$HOME/plugin_test/testspace
PATH_TO_REDMINE=$TESTSPACE/redmine
NAME_OF_PLUGIN=redmine_tracky
PATH_TO_PLUGIN=$PWD
REDMINE_VER=master
RERUN=false

if [ -d "$TESTSPACE" ]; then
	echo "RERUN OF TESTS"
	RERUN=true
fi

mkdir -p $TESTSPACE

cp test/support/* $TESTSPACE/

export RAILS_ENV=test

export REDMINE_GIT_REPO=https://github.com/redmine/redmine
export REDMINE_GIT_TAG=$REDMINE_VER
export BUNDLE_GEMFILE=$PATH_TO_REDMINE/Gemfile

# checkout redmine
if [ ! -d "$PATH_TO_REDMINE" ]; then
	git clone $REDMINE_GIT_REPO $PATH_TO_REDMINE
fi

cd $PATH_TO_REDMINE

if [ ! "$REDMINE_GIT_TAG" = "master" ];
then
  git checkout -b $REDMINE_GIT_TAG origin/$REDMINE_GIT_TAG
fi

git pull

# update plugin implementation
rm -rf $PATH_TO_REDMINE/plugins/$NAME_OF_PLUGIN
cp -R $PATH_TO_PLUGIN $PATH_TO_REDMINE/plugins/$NAME_OF_PLUGIN

if ! $RERUN
then
	echo "INSTALL DATABASE"
	mv $TESTSPACE/database.yml.semaphore config/database.yml
	mv $TESTSPACE/additional_environment.rb config/

	# install gems
	bundle install

	bundle exec rails db:create

	# run redmine database migrations
	bundle exec rake db:migrate

	# run plugin database migrations
	bundle exec rake redmine:plugins:redmine_tracky:install

	# install redmine database
	#bundle exec rake redmine:load_default_data REDMINE_LANG=en
	bundle exec rake db:structure:dump
fi

cd $PATH_TO_REDMINE

# run tests
# bundle exec rake TEST=test/unit/role_test.rb
bundle exec rake redmine:plugins:test:units NAME=redmine_tracky
bundle exec rake redmine:plugins:test:functionals NAME=redmine_tracky
bundle exec rake redmine:plugins:test:system NAME=redmine_tracky
