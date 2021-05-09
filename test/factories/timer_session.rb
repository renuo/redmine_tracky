# This will guess the User class
FactoryBot.define do
  factory :timer_session do
    timer_start { Time.zone.now - 1.hour }
    timer_end { Time.zone.now }
    comments { 'Working on tickets!' }
    user {  }
  end
end
