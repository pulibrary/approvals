require "rails_helper"

RSpec.describe StateChangesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/state_changes").to route_to("state_changes#index")
    end

    it "routes to #new" do
      expect(get: "/state_changes/new").to route_to("state_changes#new")
    end

    it "routes to #show" do
      expect(get: "/state_changes/1").to route_to("state_changes#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/state_changes/1/edit").to route_to("state_changes#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/state_changes").to route_to("state_changes#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/state_changes/1").to route_to("state_changes#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/state_changes/1").to route_to("state_changes#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/state_changes/1").to route_to("state_changes#destroy", id: "1")
    end
  end
end
