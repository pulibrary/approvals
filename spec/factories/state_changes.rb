# frozen_string_literal: true

FactoryBot.define do
  factory :state_change do
    request { FactoryBot.create(:travel_request) }
    agent { FactoryBot.create(:staff_profile) }
    action "approved"
  end
end
