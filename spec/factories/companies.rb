FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
  end
end
