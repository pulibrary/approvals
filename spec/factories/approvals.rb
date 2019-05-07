# frozen_string_literal: true

FactoryBot.define do
  factory :approval do
    request { FactoryBot.create(:travel_request) }
    approver { FactoryBot.create(:staff_profile) }
    approved false
  end
end
