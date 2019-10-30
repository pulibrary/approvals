# frozen_string_literal: true

FactoryBot.define do
  factory :staff_profile do
    user { FactoryBot.create(:user) }
    department { FactoryBot.create(:department) }
    biweekly { false }
    sequence(:given_name) { |n| "Pat#{n}" }
    sequence(:surname) { |n| "Doe#{n}" }
    location { FactoryBot.create(:location) }
    standard_hours_per_week { 36.25 }
    vacation_balance { 20 }
    sick_balance { 10 }
    personal_balance { 16 }

    trait :with_supervisor do
      after(:create) do |profile, _evaluator|
        profile.supervisor = FactoryBot.create(:staff_profile)
        profile.save
      end
    end

    trait :with_department do
      after(:create) do |profile, _evaluator|
        profile.department = FactoryBot.create(:department, :with_head)
        profile.supervisor = FactoryBot.create(:staff_profile) if profile.supervisor.blank?
        profile.supervisor.supervisor = profile.department.head
        profile.save
      end
    end

    trait :as_department_head do
      after(:create) do |profile, _evaluator|
        profile.department = FactoryBot.create(:department, head: profile)
        profile.save
      end
    end
  end
end
