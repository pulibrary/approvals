# frozen_string_literal: true

FactoryBot.define do
  factory :staff_profile do
    user { FactoryBot.create(:user) }
    department { FactoryBot.create(:department) }
    biweekly { false }
    given_name { "Pat#{srand}" }
    surname { "Doe#{srand}" }

    trait :with_supervisor do
      after(:create) do |profile, _evaluator|
        profile.supervisor = FactoryBot.create(:staff_profile)
        profile.save
      end
    end

    trait :with_department do
      after(:create) do |profile, _evaluator|
        profile.department = FactoryBot.create(:department, :with_head)
        profile.save
      end
    end
  end
end
