# frozen_string_literal: true

FactoryBot.define do
  factory :recurring_event do
    name { "event_#{srand}" }
    description { "description of #{name}" }
    url { "www.#{name}.com" }
  end
end
