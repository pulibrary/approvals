# frozen_string_literal: true

class EstimateChangeSet < Reform::Form
  property :id
  property :cost_type
  property :amount
  property :recurrence
  property :description

  EstimatePopulator = lambda { |options|
    if options[:fragment][:id].present?
      options[:collection].find { |x| x.id.to_s == (options[:fragment]["id"] || options[:fragment][:id]) }
    else
      options[:collection].append(Estimate.new)
    end
  }
end
