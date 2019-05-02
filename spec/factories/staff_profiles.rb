# frozen_string_literal: true

FactoryBot.define do
  factory :staff_profile do
    user { FactoryBot.create(:user) }
    department { FactoryBot.create(:department) }
    biweekly { false }

    trait :with_supervisor do
      supervisor { FactoryBot.create(:user) }
    end
  end
end
