# This will guess the User class
FactoryBot.define do
  factory :timer_session do
    timer_start { Time.zone.now - 1.hour }
    timer_end { Time.zone.now }
    sequence(:comments) { |n| "Working on - #{n} - tickets!" }
    finished { true }
    user {  }

    trait :with_issues do
      after(:create) do | timer_session |
        TimerSessionIssue.create!(
          timer_session_id: timer_session.id,
          issue_id: Issue.order('RANDOM()').first.id
        )
      end
    end
    
    trait :with_time_entries do
      after(:create) do | timer_session |
        TimerSessionTimeEntry.create!(
          timer_session_id: timer_session.id,
          time_entry_id: TimeEntry.order("RANDOM()").first.id
        )
      end
    end
  end
end
