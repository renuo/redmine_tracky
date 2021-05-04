# frozen_string_literal: true

require 'redmine'

require 'redmine_tracky'

Redmine::Plugin.register :redmine_tracky do
  name 'Tracky plugin'
  author 'Nick Anthony Flueckiger'
  description 'Time tracking plugin for redmine'
  version '0.0.1'
  url 'https://github.com/renuo/redmine-tracky'
  author_url 'https://github.com/Liberty'

  requires_redmine version_or_higher: '4.0.0'

  menu :application_menu, :timer_sessions, { controller: 'timer_sessions', action: 'index' },
    caption: 'TimerSessions'
end
