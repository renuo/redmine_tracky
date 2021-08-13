# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class IssueConnectorTest < ActiveSupport::TestCase
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
    status = IssueStatus.find(1)
    tracker = Tracker.find(1)
    user = User.find(2)
    @issue = Issue.generate!(tracker: tracker, status: status,
                             project_id: 1, author_id: 1)
  end

  test 'successful creation' do
    timer_session = FactoryBot.create(:timer_session,
                                      user: User.find(2))
    IssueConnector.new([@issue.id.to_s], timer_session).run
    assert_equal TimerSessionIssue.count, 1
    assert_equal TimerSessionIssue.first.issue_id, @issue.id
    assert_equal TimerSessionIssue.first.timer_session_id, timer_session.id
  end

  test 'failure on creation' do
    timer_session = FactoryBot.create(:timer_session,
                                      user: User.find(2))
    issue_connector = IssueConnector.new([(@issue.id + 1).to_s], timer_session)
    issue_connector.run
    assert_equal TimerSessionIssue.count, 0
    assert_equal issue_connector.errors.count, 1
    assert_equal issue_connector.errors, [{ invalid_issue_id: @issue.id + 1 }]
  end
end
