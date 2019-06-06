# frozen_string_literal: true

FactoryBot.define do
  factory :state_change do
    request { FactoryBot.create(:travel_request) }
    approver { FactoryBot.create(:staff_profile) }
    action "approved"
  end
end
