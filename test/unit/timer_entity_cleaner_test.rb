require File.expand_path('../test_helper', __dir__)

class TimerEntityCleanerTest < ActiveSupport::TestCase
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
    @issue = Issue.find(1)
    @timer_session = FactoryBot.create(:timer_session,
                                       user: User.find(2))
    TimerSessionIssue.create!(
      issue_id: @issue.id,
      timer_session_id: @timer_session.id
    )

    TimerSessionTimeEntry.create!(
      time_entry_id: TimeEntry.find(1),
      timer_session_id: @timer_session.id
    )
  end

  test 'removes time entries and connections to issue' do
    assert_equal 1, TimerSessionTimeEntry.count
    assert_equal 1, TimerSessionIssue.count
    TimerEntityCleaner.new(@timer_session).run
    assert_equal 0, TimerSessionTimeEntry.count
    assert_equal 0, TimerSessionIssue.count
  end
end
