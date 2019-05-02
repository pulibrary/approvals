require "rails_helper"

RSpec.describe StaffProfilesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/staff_profiles").to route_to("staff_profiles#index")
    end

    it "routes to #new" do
      expect(get: "/staff_profiles/new").to route_to("staff_profiles#new")
    end

    it "routes to #show" do
      expect(get: "/staff_profiles/1").to route_to("staff_profiles#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/staff_profiles/1/edit").to route_to("staff_profiles#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/staff_profiles").to route_to("staff_profiles#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/staff_profiles/1").to route_to("staff_profiles#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/staff_profiles/1").to route_to("staff_profiles#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/staff_profiles/1").to route_to("staff_profiles#destroy", id: "1")
    end
  end
end
