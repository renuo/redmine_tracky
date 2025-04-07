# frozen_string_literal: true

FactoryBot.define do
  factory :time_entry do
    spent_on { Time.zone.now - 1.hour }
    hours { 1 }
    user { User.current }
    issue { Issue.first }
  end
end
