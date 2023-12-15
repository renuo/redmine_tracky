# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class TimeDiscrepancyLoaderTest < ActiveSupport::TestCase
  fixtures :projects, :users, :email_addresses, :user_preferences, :members, :member_roles, :roles,
           :groups_users,
           :trackers, :projects_trackers,
           :enabled_modules,
           :versions,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations,
           :issues, :journals, :journal_details,
           :watchers,
           :custom_fields, :custom_fields_projects, :custom_fields_trackers, :custom_values,
           :time_entries

  setup do
    User.current = User.find(1)

    @timer_sessions = [1, 2, 3].map do |id|
      timer_session = FactoryBot.create(:timer_session, user: User.current)
      TimerSessionTimeEntry.create!(
        timer_session_id: timer_session.id,
        time_entry_id: id
      )
      TimerSessionIssue.create!(
        timer_session_id: timer_session.id,
        issue_id: id
      )
      timer_session
    end

    @timer_sessions.each do |timer_session|
      timer_session.time_entries.update(hours: timer_session.splittable_hours)
    end

    @timer_session = FactoryBot.create(:timer_session, user: User.current)

    3.times do
      @timer_session.time_entries.create(user: User.current, project: Project.last,
                                         hours: 1.0 / 3, spent_on: Time.zone.today)
    end
  end

  test '.uneven_timer_sessions - with all sessions valid' do
    where_time_not_adding_up = TimeDiscrepancyLoader.uneven_timer_sessions(TimerSession.where(user: User.find(1)))
    assert_equal where_time_not_adding_up, []
  end

  test '.uneven_timer_sessions - with one session invalid' do
    @timer_sessions.first.time_entries.first.update(hours: 0.05)
    where_time_not_adding_up = TimeDiscrepancyLoader.uneven_timer_sessions(TimerSession.where(user: User.find(1)))
    assert_equal 1, where_time_not_adding_up.length
    assert_kind_of TimerSession, where_time_not_adding_up.first
  end

  test 'round hours in timer session' do
    assert_equal @timer_session.time_entries.sum(&:hours), 0.99
    assert_equal @timer_session.hours, 1 # instead of 0.99
  end

  test 'ignore small discrepancies in time sum' do
    timer_sessions_in_range = TimerSession.includes(:issues, :time_entries, :timer_session_time_entries)
                                          .finished.created_by(User.current)
    non_matching_timer_sessions = TimeDiscrepancyLoader.uneven_timer_sessions(timer_sessions_in_range)

    assert non_matching_timer_sessions.ids.exclude?(@timer_session.id)
  end
end
