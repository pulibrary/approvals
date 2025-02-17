# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Delegates", type: :request do
  context "Signed in user" do
    let(:user) { create(:user) }
    let(:staff_profile) { create(:staff_profile, user:) }

    before do
      staff_profile
      sign_in user
    end

    it "works!" do
      get delegates_path
      expect(response).to have_http_status(:ok)
    end
  end

  context "Public user" do
    it "fails to allow access to page" do
      get delegates_path
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
