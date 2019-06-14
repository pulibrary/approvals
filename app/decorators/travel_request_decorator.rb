# frozen_string_literal: true
class TravelRequestDecorator < RequestDecorator
  delegate :participation, :purpose, :travel_category, to: :travel_request
  attr_reader :travel_request

  def initialize(travel_request)
    super(travel_request)
    @travel_request = travel_request
  end

  def travel_category_icon
    "lux-icon-globe"
  end

  # TODO: this title is being blocked by #207
  def title
    title_map = {
      "business" => "Business",
      "professional_development" => "Professional development",
      "discretionary" => "Discretionary"
    }
    title_map[travel_category] || "Uncategorized travel"
  end
end
