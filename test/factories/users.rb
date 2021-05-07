FactoryBot.define do
  factory :user do
    firstname { 'Nick' }
    lastname { 'Anthony' }
    login { 'AnNick' }
    mail { 'nick.flueckiger@renuo.ch' }
    status { 1 }
    language { 'en' }

    trait :admin do
      admin { 1 }
    end

    trait :as_member do
      transient do
        permissions { [] }
      end
      after(:create) do |user, evaluator|
        user.memberships << FactoryBot.create(:member, user: user, permissions: evaluator.permissions)
      end
    end
  end
end
