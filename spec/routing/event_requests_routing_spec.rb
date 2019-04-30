require "rails_helper"

RSpec.describe EventRequestsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/event_requests").to route_to("event_requests#index")
    end

    it "routes to #new" do
      expect(get: "/event_requests/new").to route_to("event_requests#new")
    end

    it "routes to #show" do
      expect(get: "/event_requests/1").to route_to("event_requests#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/event_requests/1/edit").to route_to("event_requests#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/event_requests").to route_to("event_requests#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/event_requests/1").to route_to("event_requests#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/event_requests/1").to route_to("event_requests#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/event_requests/1").to route_to("event_requests#destroy", id: "1")
    end
  end
end
