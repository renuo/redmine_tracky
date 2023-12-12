# Redmine-Tracky

Improved time tracking for Redmine

## Development Setup

```sh
git clone https://github.com/redmine/redmine
cd redmine/plugins
git clone https://github.com/renuo/redmine_tracky
cd redmine_tracky

bin/setup
```

## Production Setup

```sh
git clone https://github.com/renuo/redmine_tracky ./plugins/redmine_tracky/
RAILS_ENV=production rake redmine:plugins:redmine_tracky:install
```

### Configuration

Administration => Roles & Permissions

### Development

* Run: `rake run`
* Lint: `rake lint`
* Test: `rake test`

## Copyright

Copyright 2021-2023 [Renuo AG](https://www.renuo.ch/), published under the MIT license.
