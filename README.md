# Redmine-Tracky

Improved time tracking for redmine

## Setup

    git clone https://github.com/redmine/redmine
    cd redmine/plugins
    git clone https://github.com/renuo/redmine_tracky
    cd ../..

    bundle install
    bundle exec rake redmine:plugins:redmine_tracky:setup
    bundle exec rake redmine:plugins:redmine_tracky:install

## Installation for Redmine instance

    RAILS_ENV=production rake redmine:plugins:redmine_tracky:install

### Configuration

Administration => Roles & Permissions

### Development

#### Running

    make

#### Test

    make test

### Run
    
    cd $REDMINE_LOCATION
    rails s

### Dependency

### Tests / Checks

    cd $PLUGIN_LOCATION
    bin/check
    bin/system_check

## Copyright

Copyright 2021-2022 [Renuo AG](https://www.renuo.ch/), published under the MIT license.
