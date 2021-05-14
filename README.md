# Redmine-Tracky

Improved time tracking for redmine

## Setup

    bundle install
    bundle exec rake redmine:plugins:migrate RAILS_ENV=production

### Configuration

Administration => Roles & Permissions

### Run
    
    cd $REDMINE_LOCATION
    rails s

### Dependency

### Tests / Checks

    cd $PLUGIN_LOCATION
    bin/check
    bin/system_check

## Copyright

Copyright 2021 [Renuo AG](https://www.renuo.ch/).
