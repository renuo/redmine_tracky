# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

SimpleCov.command_name 'test:functionals'

class TimeTrackerControllerTest < ActionController::TestCase
  tests TimeTrackerController

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

  def setup
    @controller.logged_user = User.find(1)
    @request.session[:user_id] = 1
  end

  test 'upsert without login' do
    @controller.logged_user = nil
    @request.session[:user_id] = nil
    post :upsert, params: { timer_session: { comments: 'Very interesting' } }, xhr: true
    assert_response 403
  end

  test 'upsert new session: start' do
    recorded_time = Time.zone.now - 1.hour
    post :upsert, params: { timer_session: {
      timer_start: recorded_time,
      comments: 'Starting a new session',
      issue_ids: ['1']
    }}, xhr: true
    assert_response 200
  end

  test 'upsert new session: stop' do
    recorded_time = Time.zone.now - 1.hour
    post :upsert, params: { timer_session: {
      timer_start: recorded_time,
      timer_end: Time.zone.now,
      comments: 'Worked for an hour',
      issue_ids: ['1']
    }}, xhr: true
    assert_response 200
  end

  test 'upsert running session: stop' do
    FactoryBot.create(:timer_session, user: User.find(1))

    post :upsert, params: { timer_session: {
      timer_start: Time.zone.now - 1.hours,
      timer_end: Time.zone.now,
      comments: 'Worked for an hour',
      issue_ids: ['1']
    }}, xhr: true
    assert_response 200

    assert TimerSession.last.timer_start, TimerSession.first.timer_end
  end

  test 'upsert running session: cancel' do
    FactoryBot.create(:timer_session, user: User.find(1))

    post :upsert, params: { timer_session: { cancel: 'true' } }, xhr: true
    assert_response 200

    assert TimerSession.count, 0
  end
end
