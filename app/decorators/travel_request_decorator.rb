# frozen_string_literal: true
class TravelRequestDecorator < RequestDecorator
  delegate :participation, :purpose, :travel_category, :event_title, to: :travel_request
  attr_reader :travel_request

  def initialize(travel_request)
    super(travel_request)
    @travel_request = travel_request
  end

  def travel_category_icon
    "lux-icon-globe"
  end
end
