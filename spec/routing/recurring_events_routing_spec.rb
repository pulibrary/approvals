# frozen_string_literal: true
require "rails_helper"

RSpec.describe RecurringEventsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/recurring_events").to route_to("recurring_events#index")
    end

    it "routes to #new" do
      expect(get: "/recurring_events/new").to route_to("recurring_events#new")
    end

    it "routes to #show" do
      expect(get: "/recurring_events/1").to route_to("recurring_events#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/recurring_events/1/edit").to route_to("recurring_events#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/recurring_events").to route_to("recurring_events#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/recurring_events/1").to route_to("recurring_events#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/recurring_events/1").to route_to("recurring_events#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/recurring_events/1").to route_to("recurring_events#destroy", id: "1")
    end
  end
end
