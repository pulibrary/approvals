require "rails_helper"

RSpec.describe RequestsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/requests").to route_to("requests#index")
    end
  end
end
