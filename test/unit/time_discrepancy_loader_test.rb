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
  end

  test '#load_with_discrepancy_state - with all sessions valid' do
    time_discrepancy_loader = TimeDiscrepancyLoader.new(@timer_sessions)
    assert_equal false, time_discrepancy_loader.load_with_discrepancy_state.first.discrepancy_detected
  end

  test '#load_with_discrepancy_state - with one session invalid' do
    @timer_sessions.first.time_entries.first.update(hours: 0.05)
    time_discrepancy_loader = TimeDiscrepancyLoader.new(@timer_sessions)
    assert_equal true, time_discrepancy_loader.load_with_discrepancy_state.first.discrepancy_detected
  end
end
