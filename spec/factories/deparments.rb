# frozen_string_literal: true

FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "department #{n}" }
    sequence(:number, &:to_s)

    trait :with_head do
      after(:create) do |department, _evaluator|
        department.head = FactoryBot.create(:staff_profile, department:)
        department.save
      end
    end

    after(:create) do |department, _evaluator|
      if department.admin_assistants.present?
        department.admin_assistants.each do |aa|
          aa.department = department
          aa.save
        end
      end
    end
  end
end
