require File.expand_path('../../test_helper', __FILE__)

class TimeTrackerControllerTest < Redmine::ControllerTest
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
    User.current = User.find(1)
    @request.session[:user_id] = 1 # Admin!
    @project = Project.find(1)
  end

  test '#start - without login' do
    Role.find(1).add_permission! :manage_timer_sessions
    Role.all.each { |role| role.add_permission! :manage_timer_sessions }

    post :start, params: { timer_sesson: {
      timer_start: Time.zone.now - 1.hour,
      timer_end: Time.zone.now,
      comments: 'What a great working session',
      issue_ids: ['1'],
    } }

    assert_response 403
  end

  test '#start - with valid params' do
    # TODO: Fix test
    post :stop, params: { timer_sesson: {
      timer_start: Time.zone.now - 1.hour,
      timer_end: Time.zone.now,
      comments: 'What a great working session',
      issue_ids: ['1'],
    } }

    assert_response 403
  end
  
  test '#start - invalid params' do

  end

  test '#stop - valid params' do

  end

  test '#stop - invalid params' do

  end
end
