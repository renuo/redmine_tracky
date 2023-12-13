# frozen_string_literal: true

FactoryBot.define do
  factory :timer_session do
    timer_start { Time.zone.now - 1.hour }
    timer_end { Time.zone.now }
    sequence(:comments) { |n| "Working on - #{n} - tickets!" }
    finished { true }
    user { User.current }

    trait :with_issues do
      after(:create) do |timer_session|
        TimerSessionIssue.create!(timer_session:, issue: Issue.first)
      end
    end

    trait :with_time_entries do
      after(:create) do |timer_session|
        TimerSessionTimeEntry.create!(timer_session:, time_entry: TimeEntry.first)
      end
    end
  end
end
