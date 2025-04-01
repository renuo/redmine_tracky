# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

SimpleCov.command_name 'test:units'

class TimeSplitterTest < ActiveSupport::TestCase
  fixtures :projects, :users, :email_addresses, :user_preferences, :members, :member_roles, :roles,
           :groups_users,
           :trackers, :projects_trackers,
           :enabled_modules,
           :versions,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations,
           :issues, :journals, :journal_details,
           :watchers,
           :custom_fields, :custom_fields_projects, :custom_fields_trackers, :custom_values
  setup do
    @issue = Issue.find(1)
    @timer_session = FactoryBot.create(:timer_session,
                                       user: User.find(2))
    TimerSessionIssue.create!(
      issue: @issue,
      timer_session: @timer_session
    )
  end

  test 'creates time entry on one issue' do
    assert_equal @timer_session.issues.count, 1

    time_splitter = TimeSplitter.new(@timer_session, @timer_session.issues)
    time_splitter.create_time_entries
    assert_equal TimerSessionTimeEntry.count, 1
    assert_equal 1, 0
  end

  test 'splits time entries on multiple issues' do
    TimerSessionIssue.create!(
      issue: Issue.find(2),
      timer_session: @timer_session
    )
    assert_equal @timer_session.issues.count, 2

    time_splitter = TimeSplitter.new(@timer_session, @timer_session.issues)
    time_splitter.create_time_entries
    assert_equal 2, TimerSessionTimeEntry.count
    assert_equal 0.5, TimeEntry.last.hours
  end
end
