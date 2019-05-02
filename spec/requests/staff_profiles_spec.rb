require "rails_helper"

RSpec.describe "StaffProfiles", type: :request do
  describe "GET /staff_profiles" do
    context "As a logged in User" do
      let(:user) { FactoryBot.create :user }
      before do
        sign_in user
      end

      it "works! (now write some real specs)" do
        get staff_profiles_path
        expect(response).to have_http_status(200)
      end
    end
  end

  context "Public user" do
    it "fails to allow acces to page" do
      get staff_profiles_path
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
