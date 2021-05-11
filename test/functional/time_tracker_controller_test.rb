require File.expand_path('../../test_helper', __FILE__)

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

  test 'start _ without login' do
    @controller.logged_user = nil
    @request.session[:user_id] = nil
    post :start, params: { timer_session: { comments: 'Very interesting' } }, xhr: true
    assert_response 403
  end

  test 'stop _ without login' do
    @controller.logged_user = nil
    @request.session[:user_id] = nil
    post :stop, params: { timer_session: { comments: 'Very interesting' } }, xhr: true

    assert_response 403
  end

  test 'start _ with valid params' do
    post :start, params: { timer_session: {
      timer_start: Time.zone.now - 1.hour,
      timer_end: Time.zone.now,
      comments: 'What a great working session',
      issue_ids: ['1'],
    } }, xhr: true

    assert_response 200
  end

  test 'start _ invalid params' do
    post :start, params: { timer_session: {
      timer_start: Time.zone.now,
      timer_end: Time.zone.now - 1.hour,
      comments: 'What a great working session',
      issue_ids: ['1'],
    } }, xhr: true

    assert_response 200
    refute TimerSession.last.finished?
    assert response.body.include?(I18n.t('activerecord.errors.models.timer_session.attributes.timer_start.after_end'))
  end

  test 'start _ invalid issues' do
    post :start, params: { timer_session: {
      timer_start: Time.zone.now - 1.hour,
      timer_end: Time.zone.now,
      comments: 'What a great working session',
      issue_ids: ['100'],
    } }, xhr: true

    assert_response 200
  end
  
  test 'stop _ valid params' do
    post :start, params: { timer_session: {
      timer_start: Time.zone.now - 1.hour,
      comments: 'What a great working session',
      issue_ids: ['1'],
    } }, xhr: true

    assert_response 200

    post :stop, params: { timer_session: { comments: 'End' } }, xhr: true
    assert_response 200

    assert_equal TimerSession.last.finished?, true
  end

  test 'stop _ cancel' do
    post :start, params: { timer_session: {
      timer_start: Time.zone.now - 1.hour,
      comments: 'What a great working session',
      issue_ids: ['1'],
    } }, xhr: true

    post :stop, params: { cancel: 'true' ,timer_session: {
      timer_start: Time.zone.now - 1.hour,
    } }, xhr: true

    assert_response 200
    assert_equal TimerSession.count, 0
  end

  test 'update _ valid params' do
    post :start, params: { timer_session: {
      timer_start: Time.zone.now - 1.hour,
      comments: 'What a great working session',
      issue_ids: ['1'],
    } }, xhr: true

    post :update, params: { timer_session: {
      comments: 'NEW COMMENT'
    } }, xhr: true

    assert_equal 'NEW COMMENT', TimerSession.last.comments
  end

  test 'stop _ invalid params' do
    post :start, params: { timer_session: {
      timer_start: Time.zone.now - 1.hour,
      comments: 'What a great working session',
      issue_ids: ['1'],
    } }, xhr: true

    post :stop, params: { timer_session: {
      timer_end: Time.zone.now - 2.hour
    } }, xhr: true

    assert_response 200
    refute TimerSession.last.finished?
  end
end
