# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class IssueSearcherTest < ActiveSupport::TestCase
  fixtures :projects, :users, :email_addresses, :user_preferences, :members, :member_roles, :roles,
           :groups_users,
           :trackers, :projects_trackers,
           :versions,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations

  setup do
    User.current = User.find(2)
    @service = IssueSearcher.new
    @issues = [
      FactoryBot.create(:issue, id: 100, subject: 'Very special Renuo issue', project: Project.first),
      FactoryBot.create(:issue, id: 101, subject: 'Second special Renuo issue', project: Project.second),
      FactoryBot.create(:issue, :closed, id: 102, subject: 'Closed issue', project: Project.third)
    ]
  end

  test 'call - search by id' do
    search_term = @issues[0].id.to_s
    assert_equal [@issues[0]], @service.call(search_term, Issue.all)
  end

  test 'call - search by subject' do
    search_term = @issues[0].subject
    assert_equal [@issues[0]], @service.call(search_term, Issue.all)
  end

  test 'call - search by project name' do
    search_term = @issues[0].project.name
    assert_equal @issues[0], @service.call(search_term, Issue.all)[0]
  end

  test 'call - filters closed issues' do
    search_term = @issues.last.subject
    assert_equal [], @service.call(search_term, Issue.all)
  end

  test 'call - hits by id are first' do
    second_issue = FactoryBot.create(:issue, id: 103, subject: '100th issue', project: Project.first)

    search_term = '100'
    assert_equal [@issues[0], second_issue], @service.call(search_term, Issue.all)
  end
end
