# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class TimeRebalancerTest < ActiveSupport::TestCase
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
      time_entry_id: TimeEntry.find(1).id,
      timer_session_id: @timer_session.id
    )
    @timer_session.reload
  end

  test '#rebalance_entries - issues changed' do
    TimeRebalancer.new([Issue.find(2).id], @timer_session).rebalance_entries
    @timer_session.reload
    assert_equal 1, TimerSessionIssue.count
    assert_equal [2], @timer_session.issue_ids
  end

  test '#rebalance_entries - issues not changed - times changed' do
    @timer_session.update(timer_start: Time.zone.now - 2.hours)
    timer_before_change = @timer_session.time_entries.first.hours
    TimeRebalancer.new(@timer_session.issue_ids, @timer_session).rebalance_entries

    assert_equal (@timer_session.splittable_hours.to_f / @timer_session.issue_ids.length).round(2),
                 TimeEntry.find(
                   @timer_session.time_entries.first.id
                 ).hours.round(2)
  end

  test '#rebalance_entries - issues not changed - comments changed' do
    @timer_session.update(comments: 'Different comment')
    TimeRebalancer.new(@timer_session.issue_ids, @timer_session).rebalance_entries

    assert_equal 'Different comment', TimeEntry.find(
      @timer_session.time_entries.first.id
    ).comments
  end

  test '#force_rebalance' do
    issue_id = @issue.id
    assert_equal 1, TimerSessionTimeEntry.count
    assert_equal 1, TimerSessionIssue.count

    TimeRebalancer.new([@issue.id.to_s], @timer_session).force_rebalance

    assert_equal 1, TimerSessionTimeEntry.count
    assert_equal 1, TimerSessionIssue.count
    assert_equal issue_id, @timer_session.issues.first.id
  end
end
