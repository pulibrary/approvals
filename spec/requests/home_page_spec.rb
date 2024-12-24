# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Home Page", type: :request do
  describe "GET /" do
    context "Signed in user" do
      let(:user) { create(:user) }
      let(:staff_profile) { create(:staff_profile, user:) }

      before do
        staff_profile
        sign_in user
      end

      it "works! (now write some real specs)" do
        create(:absence_request)
        create(:travel_request)

        get root_path
        expect(response).to be_redirect
        expect(response.redirect_url).to eq(my_requests_url)
      end
    end

    context "Public user" do
      it "allows access to home page" do
        get root_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
