FactoryBot.define do
  factory :invite do
    trait :recipient_is_existing_user do
      email { create(:user).email }
    end

    trait :recipient_is_new_user do
      email
    end

    after(:build) do |invite|
      invite.sender = create(:user)
      invite.invitable = create(:company)
      invite.invitable.users << invite.sender
    end
  end
end
