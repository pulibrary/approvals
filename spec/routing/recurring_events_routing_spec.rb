# frozen_string_literal: true
require "rails_helper"

RSpec.describe RecurringEventsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/recurring_events").to route_to("recurring_events#index")
    end

    it "routes to #combine" do
      expect(get: "/recurring_events/combine").to route_to("recurring_events#combine")
    end
  end
end
