# frozen_string_literal: true

FactoryBot.define do
  factory :note do
    content { "Note about something" }
    creator { FactoryBot.create(:staff_profile) }
  end
end
