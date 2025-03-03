# frozen_string_literal: true

require 'redmine'

Redmine::Plugin.register :redmine_tracky do
  name 'Tracky plugin'
  author 'Nick Anthony Flueckiger'
  description 'Time tracking plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/renuo/redmine-tracky'
  author_url 'https://github.com/Liberatys'

  requires_redmine version_or_higher: '4.0.0'

  project_module :redmine_tracky do
    permission :view_polls, polls: :index
    permission :vote_polls, polls: :vote
  end

  default_settings = {
    'displayed_hours_rounding' => 2,
    'max_hours_recorded_per_day' => 24,
    'max_hours_recorded_per_session' => 24,
    'visible_hints' => true,
    'min_hours_to_record' => 0.01
  }

  settings default: default_settings, partial: 'settings/redmine_tracky_settings'

  menu :application_menu, :timer_sessions, { controller: 'timer_sessions', action: 'index' },
       caption: 'Tracky', if: proc { User.current.allowed_to_globally?(action: :index, controller: 'timer_sessions') }

  menu :top_menu, :timer_sessions, { controller: 'timer_sessions', action: 'index' },
       caption: 'Tracky', if: proc { User.current.allowed_to_globally?(action: :index, controller: 'timer_sessions') }

  project_module :timer_sessions do
    permission :manage_timer_sessions, {
      timer_sessions: %i[index create continue update edit patch
                         destroy report time_error report time_error rebalance],
      time_tracker: %i[create update destroy]
    }, require: :loggedin

    permission :index_timer_sessions, {
      timer_sessions: %i[index]
    }, require: :loggedin

    permission :create_timer_sessions, {
      time_tracker: %i[create]
    }, require: :loggedin

    permission :stop_timer_sessions, {
      time_tracker: %i[update]
    }, require: :loggedin

    permission :cancel_timer_sessions, {
      time_tracker: %i[destroy]
    }, require: :loggedin

    permission :query_report, {
      timer_sessions: %i[report]
    }, require: :loggedin

    permission :edit_timer_sessions, {
      timer_sessions: %i[update patch edit time_error rebalance]
    }, require: :loggedin

    permission :delete_timer_sessions, {
      timer_sessions: %i[destroy]
    }, require: :loggedin
  end
end
