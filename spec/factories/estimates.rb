# frozen_string_literal: true

FactoryBot.define do
  factory :estimate do
    cost_type { "lodging (per night)" }
    amount { 50.0 }
    recurrence { 3 }
  end
end
