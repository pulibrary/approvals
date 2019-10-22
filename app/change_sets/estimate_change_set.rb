# frozen_string_literal: true
class EstimateChangeSet < Reform::Form
  property :cost_type
  property :amount
  property :recurrence
  property :description

  EstimatePopulator = lambda { |collection:, **|
    collection.append(Estimate.new)
  }
end
