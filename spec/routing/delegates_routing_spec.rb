# frozen_string_literal: true
require "rails_helper"

RSpec.describe DelegatesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/delegates").to route_to("delegates#index")
    end

    it "routes to #new" do
      expect(get: "/delegates/new").to route_to("delegates#new")
    end

    it "routes to #show" do
      expect(get: "/delegates/1").to route_to("delegates#show", id: "1")
    end

    it "routes to #assume" do
      expect(get: "/delegates/1/assume").to route_to("delegates#assume", id: "1")
    end

    it "routes to #cancel" do
      expect(get: "/delegates/cancel").to route_to("delegates#cancel")
    end

    it "routes to #edit" do
      expect(get: "/delegates/1/edit").to route_to("delegates#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/delegates").to route_to("delegates#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/delegates/1").to route_to("delegates#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/delegates/1").to route_to("delegates#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/delegates/1").to route_to("delegates#destroy", id: "1")
    end
  end
end
