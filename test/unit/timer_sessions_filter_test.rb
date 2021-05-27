# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

SimpleCov.command_name 'test:units'

class TimerSessionsFilterTest < ActiveSupport::TestCase
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
      issue_id: @issue.id,
      timer_session_id: @timer_session.id
    )

    @other_session = FactoryBot.create(:timer_session,
                                       user: User.find(2),
                                       timer_start: Time.zone.now - 15.days)
    TimerSessionIssue.create!(
      issue_id: @issue.id,
      timer_session_id: @other_session.id
    )
  end

  test 'filter' do
    filter = Filtering::TimerSessionsFilter.new({ min_date: Time.zone.now.to_date })
    assert_equal 1, filter.apply(TimerSession.all).count

    filter = Filtering::TimerSessionsFilter.new({ min_date: (Time.zone.now - 20.days).to_date })
    assert_equal 2, filter.apply(TimerSession.all).count
  end
end
