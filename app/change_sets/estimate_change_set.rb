# frozen_string_literal: true
class EstimateChangeSet < Reform::Form
  property :cost_type
  property :amount
  property :recurrence

  EstimatePopulator = lambda { |collection:, **|
    collection.append(Estimate.new)
  }
end
