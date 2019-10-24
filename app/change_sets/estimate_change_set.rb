# frozen_string_literal: true
class EstimateChangeSet < Reform::Form
  property :id
  property :cost_type
  property :amount
  property :recurrence
  property :description

  EstimatePopulator = lambda { |collection:, fragment:, **|
    if fragment[:id].present?
      collection.find { |x| x.id.to_s == (fragment["id"] || fragment[:id]) }
    else
      collection.append(Estimate.new)
    end
  }
end
