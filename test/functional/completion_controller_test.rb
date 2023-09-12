# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

SimpleCov.command_name 'test:functionals'

class CompletionControllerTest < ActionController::TestCase
  tests CompletionController

  fixtures :projects, :users, :email_addresses, :user_preferences, :members, :member_roles, :roles,
           :groups_users,
           :trackers, :projects_trackers,
           :versions,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations,
           :issues

  def setup
    @controller.logged_user = User.find(1)
    @request.session[:user_id] = 1
  end

  test 'issues - search by term' do
    issue = FactoryBot.create(:issue, id: 100, subject: 'Test issue for Renuo')

    get :issues, params: { term: issue.subject }

    assert_response 200
    assert_equal 'application/json; charset=utf-8', response.content_type
    assert_equal [
                   {
                     "id" => issue.id,
                     "label" => "eCookbook - Bug #100: Test issue for Renuo",
                     "subject" => "Test issue for Renuo",
                     "value" => 100,
                     "project" => "eCookbook"
                   }
                 ],
                 JSON.parse(response.body)
  end
end
