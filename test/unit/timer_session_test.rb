# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class TimerSessionTest < ActiveSupport::TestCase
  fixtures :projects, :users, :email_addresses, :user_preferences, :members, :member_roles, :roles,
           :issues,
           :time_entries

  setup do
    @timer_session = FactoryBot.create(:timer_session, user: User.current)

    TimerSessionIssue.create!(
      issue_id: Issue.find(1).id,
      timer_session_id: @timer_session.id
    )

    TimerSessionTimeEntry.create!(
      timer_session_id: @timer_session.id,
      time_entry_id: TimeEntry.find(1).id
    )
  end

  test '#session_finished?' do
    assert_equal @timer_session.session_finished?, true

    @timer_session.timer_end = nil
    assert_equal @timer_session.session_finished?, false
  end

  test 'recorded_hours' do
    assert_equal @timer_session.recorded_hours, TimeEntry.find(1).hours
    @timer_session.time_entries.destroy_all
    assert_equal @timer_session.recorded_hours, 0
  end

  test 'comment_present' do
    assert @timer_session.valid?
    @timer_session.comments = nil
    assert_not @timer_session.valid?
  end

  test 'issues_selected' do
    assert @timer_session.valid?
    @timer_session.issues.destroy_all
    assert_not @timer_session.valid?
  end

  test 'start_before_end_date' do
    assert @timer_session.valid?
    @timer_session.timer_start = @timer_session.timer_end
    assert_not @timer_session.valid?
  end

  test 'limit_recorded_hours' do
    assert @timer_session.valid?
    @timer_session.update(timer_end: Time.zone.now + 2.days)
    assert_not @timer_session.valid?
  end
end
