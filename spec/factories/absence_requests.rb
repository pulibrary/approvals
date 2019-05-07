# frozen_string_literal: true

FactoryBot.define do
  factory :absence_request do
    creator { FactoryBot.create(:staff_profile) }
  end
end
