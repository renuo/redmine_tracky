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

  # auth spec

  test '#create without login'
    @controller.logged_user = nil
    @request.session[:user_id] = nil
    post :create, params: { timer_session: { comments: 'Very interesting' } }, xhr: true
    assert_response 403
  end

  test '#create without login'
    @controller.logged_user = nil
    @request.session[:user_id] = nil
    post :create, params: { timer_session: { comments: 'Very interesting' } }, xhr: true
    assert_response 403
  end
  
  test '#destroy without login'
    @controller.logged_user = nil
    @request.session[:user_id] = nil
    post :destroy, params: { timer_session: { comments: 'Very interesting' } }, xhr: true
    assert_response 403
  end

  # create tests

  test 'create - complete params' do
    recorded_time = Time.zone.now - 1.hour
    assert_equal 0, TimerSession.count
    post :create, params: { timer_session: {
      timer_start: recorded_time,
      comments: 'Starting a new session',
      issue_ids: ['1']
    } }, xhr: true
    assert_equal 1, TimerSession.count
    assert_equal TimerSession.last.finished, true
    assert_response 200
  end

  test 'create - end time presetn' do
    recorded_time = Time.zone.now - 1.hour
    assert_equal 0, TimerSession.count
    post :create, params: { timer_session: {
      timer_start: recorded_time,
      comments: 'Starting a new session',
      issue_ids: ['1']
    } }, xhr: true
    assert_equal 1, TimerSession.count
    assert_equal TimerSession.last.finished, true
    assert_response 200
  end

  test '#update: stop' do
    recorded_time = Time.zone.now - 1.hour
    post :update, params: { timer_session: {
      timer_start: recorded_time,
      timer_end: Time.zone.now,
      comments: 'Worked for an hour',
      issue_ids: ['1']
    } }, xhr: true
    assert_response 200
  end

  test '#update: invalid' do
    FactoryBot.create(:timer_session, user: User.find(1))

    post :create_or_update, params: { timer_session: {
      timer_start: Time.zone.now - 1.hours,
      timer_end: Time.zone.now,
      comments: 'Worked for an hour',
      issue_ids: ['1']
    } }, xhr: true
    assert_response 200

    assert TimerSession.last.timer_start, TimerSession.first.timer_end
  end

  test '#destroy: found' do
    FactoryBot.create(:timer_session, user: User.find(1), finished: false)

    delete :cancel, xhr: true
    assert_response 200

    assert TimerSession.count, 0
  end

  test '#destroy: not found' do
    post :cancel, xhr: true
    assert_response 404

    assert TimerSession.count, 0
  end
end
