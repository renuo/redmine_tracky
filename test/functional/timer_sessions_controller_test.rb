require File.expand_path('../../test_helper', __FILE__)

class TimerSessionsControllerTest < Redmine::ControllerTest
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
           :custom_fields, :custom_fields_projects, :custom_fields_trackers, :custom_values

  setup do
    @issue = Issue.find(1)
    @timer_session = FactoryBot.create(:timer_session,
                                       user: User.find(2))
    TimerSessionIssue.create!(
      issue_id: @issue.id,
      timer_session_id: @timer_session.id
    )

    session[:user_id] = 1 # Admin!
    User.current = User.find(1)
  end

  test 'access without login' do
    @request.session[:user_id] = nil
    get :index
    assert_response 403
  end

  test '#index list view' do
    get :index

    assert_response 200
  end

  test '#update' do

  end

  test '#destroy' do
    delete(
      :destroy,
      params: {
        id: @timer_session.id,
      }
    )
    assert_response 302
  end

  test '#edit' do
    get(:edit, params: {id: @timer_session.id})

    assert_response 200
  end

  test '#report' do

  end

  test '#rebalance' do
    post(
      :rebalance,
      params: {
        id: @timer_session.id,
      }
    )

    assert_response 200
    assert_equal @timer_session.reload.time_entries.first.hours, @timer_session.hours
  end
end
