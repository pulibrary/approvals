# frozen_string_literal: true

FactoryBot.define do
  factory :department do
    sequence(:name) { "department #{srand}" }

    trait :with_head do
      after(:create) do |department, _evaluator|
        department.head = FactoryBot.create(:staff_profile)
        department.save
      end
    end
  end
end
