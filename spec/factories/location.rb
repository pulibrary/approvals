# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    sequence(:building) { |n| "Building #{n}" }
  end
end
