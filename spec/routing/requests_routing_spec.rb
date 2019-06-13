# frozen_string_literal: true
require "rails_helper"

RSpec.describe RequestsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/my_requests").to route_to("requests#my_requests")
    end
  end
end
