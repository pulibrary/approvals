# frozen_string_literal: true

FactoryBot.define do
  factory :recurring_event do
    sequence(:name) { |n| "Event #{n}" }
    description { "description of #{name}" }
    url { "www.#{name}.com" }
  end
end
