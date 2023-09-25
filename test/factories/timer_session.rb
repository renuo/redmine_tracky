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

    trait :with_unrounded_time_entries do
      after(:create) do |timer_session|
        3.times do
          e = TimeEntry.create(user: User.current, project: Project.last, hours: 1.0 / 3, spent_on: Time.zone.today)
          TimerSessionTimeEntry.create!(timer_session:, time_entry: e)
        end
      end
    end
  end
end
