FactoryBot.define do
  factory :project do
    name { 'Weber-Baumer' }
    description { 'Building a website about selling trees' }
    homepage { 'www.weber-baumer.ch' }
    sequence(:identifier) { |n| "#{name}_#{n}" }
    is_public { true }
    status { 1 }
    after(:create) do |project|
      project.enabled_modules.create name: :redmine_tracky
    end
  end
end
