require "rails_helper"

RSpec.describe EventInstancesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/event_instances").to route_to("event_instances#index")
    end

    it "routes to #new" do
      expect(get: "/event_instances/new").to route_to("event_instances#new")
    end

    it "routes to #show" do
      expect(get: "/event_instances/1").to route_to("event_instances#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/event_instances/1/edit").to route_to("event_instances#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/event_instances").to route_to("event_instances#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/event_instances/1").to route_to("event_instances#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/event_instances/1").to route_to("event_instances#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/event_instances/1").to route_to("event_instances#destroy", id: "1")
    end
  end
end
