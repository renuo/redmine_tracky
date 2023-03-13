# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class TimerSessionsControllerTest < ActionController::TestCase
  tests TimerSessionsController

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

  def setup
    @issue = Issue.find(1)
    @time_entry = TimeEntry.find(1)
    @user = User.find(1)
    @timer_session = FactoryBot.create(:timer_session,
                                       user: @user)
    TimerSessionTimeEntry.create!(
      time_entry: @time_entry,
      timer_session_id: @timer_session.id
    )

    @controller.logged_user = User.find(1)
    @request.session[:user_id] = 1
  end

  test 'access without login' do
    @request.session[:user_id] = nil
    get(:index)
    assert_response 403
  end

  test 'index list view' do
    get(:index)
    assert_response 200
    assert response.body.include?(@issue.subject)
    assert response.body.include?(@timer_session.splittable_hours.round(2).to_s)
  end

  test 'index with different server time zone' do
    @user.preference.update(time_zone: 'Tijuana')
    get(:index)
    assert_response 200
    assert response.body.include?('data-timer-timezone-value="-[420480]"')
  end

  test 'index - with filter' do
    get(:index, params: {
          filter: {
            min_date: Time.zone.now.to_date + 10.days
          }
        })
    assert_response 200
    assert_not response.body.include?(@issue.subject)
    assert_not response.body.include?(@timer_session.splittable_hours.round(2).to_s)
  end

  test 'update' do
    put(:update, params: { id: @timer_session.id, timer_session: { comments: 'NEW IPA TOPIC' } }, xhr: true)

    assert_response 200
    assert @timer_session.comments, 'NEW IPA TOPIC'
  end

  test 'continue' do
    start_timer_sessions_count = TimerSession.all.count
    post(:continue, params: { id: @timer_session.id })
    assert_response 302
    assert TimerSession.all.count, start_timer_sessions_count + 1
  end

  test 'update with invalid data' do
    comments = @timer_session.comments
    put(:update, params: { id: @timer_session.id, timer_session: { comments: '' } }, xhr: true)

    assert_response 200
    assert_equal @timer_session.comments, comments
  end

  test '#destroy' do
    delete(
      :destroy,
      params: {
        id: @timer_session.id
      }
    )

    assert_response 302
  end

  test '#edit' do
    get :edit, params: { id: @timer_session.id }, xhr: true

    assert_response 200
  end

  test '#report' do
    post(
      :report,
      params: { work_report_query: {
        date: Time.zone.now.to_date,
        period: 'week'
      } }
    )

    assert_response 302
  end

  test 'rebalance' do
    post(
      :rebalance,
      params: {
        id: @timer_session.id
      }
    )

    assert_response 302

    expected_hours = @timer_session.reload.time_entries.first.hours.round(2)

    assert_equal expected_hours, @timer_session.hours.round(2)
  end

  test 'time_error' do
    get(:time_error, params: { id: @timer_session.id }, xhr: true)
    assert_response 200
    assert response.body.include?(I18n.t('resolution_options.options',
                                         scope: 'timer_sessions.messaging.errors.discrepancy_in_time_sum'))
  end
end
