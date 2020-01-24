# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Home Page", type: :request do
  describe "GET /" do
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

        get root_path
        expect(response).to be_redirect
        expect(response.redirect_url).to eq(my_requests_url)
      end
    end

    context "Public user" do
      it "allows access to home page" do
        get root_path
        expect(response).to have_http_status(200)
      end
    end
  end
end
