# frozen_string_literal: true

class EstimateDecorator
  attr_reader :estimate
  delegate :cost_type, :description, :recurrence, :amount, to: :estimate

  def initialize(estimate)
    @estimate = estimate
  end

  def data
    { cost_type: self.class.cost_type_to_label(cost_type),
      note: description || "",
      recurrence: recurrence,
      amount: format("%.2f", amount),
      total: format("%.2f", total) }
  end

  def total
    recurrence * amount
  end

  class << self
    def cost_options_json
      cost_types = COST_TYPE_TO_LABEL.sort_by { |_key, value| value }
      strings = cost_types.map do |key, value|
        "{label: '#{value}', value: '#{key}'}"
      end
      "[#{strings.join(',')}]"
    end

    def cost_type_to_label(type)
      COST_TYPE_TO_LABEL[type.to_sym]
    end

    COST_TYPE_TO_LABEL = {
      ground_transportation: "Ground transportation",
      lodging: "Lodging (per night)",
      meals: "Meals and related expenses (daily)",
      misc: "Miscellaneous",
      registration: "Registration fee",
      rental_vehicle: "Car rental",
      air: "Airfare",
      taxi: "Taxi",
      personal_auto: "Mileage - personal car",
      transit_other: "Other transit",
      train: "Train",
      parking: "Parking"
    }.freeze
  end
end
