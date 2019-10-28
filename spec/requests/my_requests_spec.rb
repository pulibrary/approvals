# frozen_string_literal: true
require "rails_helper"

RSpec.describe "My Requests", type: :request do
  describe "GET /my_requests" do
    context "Signed in user" do
      let(:user) { FactoryBot.create :user }
      let(:staff_profile) { FactoryBot.create :staff_profile, user: user }
      before do
        staff_profile
        sign_in user
      end

      it "works! (now write some real specs)" do
        FactoryBot.create(:absence_request)
        FactoryBot.create(:travel_request)

        get my_requests_path
        expect(response).to have_http_status(200)
      end
    end

    context "Public user" do
      it "fails to allow access to page" do
        get my_requests_path
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
