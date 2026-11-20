# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class TimerSessionPrefillTest < ActiveSupport::TestCase
  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :trackers, :projects_trackers, :enabled_modules, :issue_statuses,
           :enumerations, :workflows, :issues

  def setup
    @user = User.find(1)
    @issue = Issue.find(1)
  end

  test 'builds an unsaved session from params' do
    params = ActionController::Parameters.new(
      issue_ids: [@issue.id], comments: '  Pairing  ',
      timer_start: '2026-01-05T09:00:00Z', timer_end: '2026-01-05T10:30:00Z'
    )
    session = TimerSessionPrefill.new(params, user: @user).build

    assert session.new_record?
    assert_equal 'Pairing', session.comments
    assert_equal [@issue], session.issues.to_a
    assert_equal Time.utc(2026, 1, 5, 9), session.timer_start
    assert_equal Time.utc(2026, 1, 5, 10, 30), session.timer_end
  end

  test 'ignores unknown issues and invalid times' do
    params = ActionController::Parameters.new(issue_ids: %w[0 999999 abc], timer_start: 'not-a-time')
    prefill = TimerSessionPrefill.new(params, user: @user)

    assert_not prefill.prefilled?
    assert_empty prefill.build.issues
    assert_nil prefill.build.timer_start
  end

  test 'is not prefilled without params' do
    assert_not TimerSessionPrefill.new(nil, user: @user).prefilled?
  end

  test 'truncates overly long comments' do
    params = ActionController::Parameters.new(comments: 'a' * 1000)

    assert_equal TimerSessionPrefill::MAX_COMMENT_LENGTH,
                 TimerSessionPrefill.new(params, user: @user).build.comments.length
  end

  test 'share_params round-trips a timer session' do
    timer_session = FactoryBot.create(:timer_session, user: @user)
    TimerSessionIssue.create!(issue: @issue, timer_session_id: timer_session.id)
    shared = TimerSessionPrefill.share_params(timer_session.reload)

    assert_equal [@issue.id], shared[:issue_ids]
    assert_equal timer_session.timer_start.utc.iso8601, shared[:timer_start]
    assert_equal timer_session.comments, shared[:comments]
  end
end
