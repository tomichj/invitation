FactoryBot.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    email

    trait :with_company do
      after(:create) { |user| user.companies << create(:company) }
    end
  end
end
