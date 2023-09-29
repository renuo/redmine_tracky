# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class CompletionControllerTest < ActionController::TestCase
  tests CompletionController

  fixtures :projects, :users, :email_addresses, :user_preferences, :members, :member_roles, :roles,
           :groups_users,
           :trackers, :projects_trackers,
           :versions,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations,
           :issues

  setup do
    @controller.logged_user = User.find(1)
    @request.session[:user_id] = 1
  end

  test 'issues - returns matching issues for given term' do
    issue = FactoryBot.create(:issue, id: 100, subject: 'Test issue for Renuo')

    get :issues, params: { term: issue.subject }

    assert_response :success
    assert_equal 'application/json; charset=utf-8', response.content_type
    assert_json_response_matches_issue(issue)
  end

  test 'issues - handles request without term' do
    get :issues
    assert_response :success
    assert_equal 'application/json; charset=utf-8', response.content_type
  end

  private

  def assert_json_response_matches_issue(issue)
    expected = [{
      'id' => issue.id,
      'label' => "#{issue.project} - #{issue.tracker} ##{issue.id}: #{issue.subject}",
      'subject' => issue.subject,
      'value' => issue.id,
      'project' => issue.project.to_s
    }]
    assert_equal expected, JSON.parse(response.body)
  end
end
