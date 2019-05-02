class Estimate < ApplicationRecord
  belongs_to :request
  enum cost_type: {
    ground_transportation: "ground_transportation",
    lodging: "lodging",
    meals: "meals",
    misc: "misc",
    registration: "registration",
    rental_vehicle: "rental_vehicle",
    air: "air",
    taxi: "taxi",
    personal_auto: "personal_auto",
    transit_other: "transit_other",
    train: "train"
  }
end
