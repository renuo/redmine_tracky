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
    renuo_project = create(:project, name: 'Renuo Project', identifier: 'renuo_project')
    @projects = [renuo_project, Project.first, Project.second, Project.third]
    @issues = [
      create(:issue, id: 100, subject: 'Very special Renuo issue', project: @projects[0]),
      create(:issue, id: 101, subject: 'Second special Renuo issue', project: @projects[1]),
      create(:issue, :closed, id: 102, subject: 'Closed issue', project: @projects[2]),
    ]
  end

  test 'call - search by id' do
    search_term = '100'
    assert_equal [@issues[0]], @service.call(search_term, Issue.all)
  end

  test 'call - search by subject' do
    search_term = 'Very special Renuo issue'
    assert_equal [@issues[0]], @service.call(search_term, Issue.all)
  end

  test 'call - search by project name' do
    search_term = 'Renuo Project'
    assert_includes @service.call(search_term, Issue.all), @issues[0]
  end

  test 'call - filters closed issues' do
    search_term = 'Closed issue'
    assert_equal [], @service.call(search_term, Issue.all)
  end

  test 'call - hits by id are first' do
    second_issue = FactoryBot.create(:issue, id: 103, subject: '100th issue', project: Project.first)

    search_term = '100'
    assert_equal [@issues[0], second_issue], @service.call(search_term, Issue.all)
  end

  test 'call - hits by project name are ordered by time entries count (descending)' do
    4.times { @issues[0].time_entries.create(hours: 1, user: User.current, spent_on: Date.yesterday) }
    second_issue = FactoryBot.create(:issue, id: 104, subject: 'Very special Renuo issue', project: @projects[0])
    3.times { second_issue.time_entries.create!(hours: 1, user: User.current, spent_on: Date.yesterday) }

    search_term = 'Renuo Project'
    actual_issues = @service.call(search_term, Issue.all)

    assert_equal @issues[0], actual_issues[0]
    assert_equal second_issue, actual_issues[1]
  end

  test 'call - hits by subject are ordered by id (descending)' do
    search_term = 'special Renuo issue'
    actual_issues = @service.call(search_term, Issue.all)

    assert_equal @issues[1], actual_issues[0]
    assert_equal @issues[0], actual_issues[1]
  end
end
