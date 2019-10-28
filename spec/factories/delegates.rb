# frozen_string_literal: true

FactoryBot.define do
  factory :delegate do
    delegate { FactoryBot.create(:staff_profile) }
    delegator { FactoryBot.create(:staff_profile) }
  end
end
