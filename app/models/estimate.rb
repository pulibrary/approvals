# frozen_string_literal: true
class Estimate < ApplicationRecord
  belongs_to :request
  enum cost_type: {
    ground_transportation: "ground transportation",
    lodging: "lodging (per night)",
    meals: "meals and related expenses (daily)",
    misc: "miscellaneous",
    registration: "registration fee",
    rental_vehicle: "car rental",
    air: "airfare",
    taxi: "taxi",
    personal_auto: "mileage - personal car",
    transit_other: "other transit",
    train: "train"
  }
end
