# frozen_string_literal: true

FactoryBot.define do
  factory :issue do
    subject { 'Test issue' }
    description { 'Test issue description' }
    author { User.first }
    status { IssueStatus.first }
    project { Project.first }
    tracker { Tracker.first }
    priority { create(:issue_priority) }
  end

  factory :issue_priority do
    name { 'EOD' }
  end

  factory :issue_status do
    name { 'New' }
  end
end
