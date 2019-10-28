# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Departments", type: :request do
  context "As a logged in User" do
    let(:user) { FactoryBot.create :user }
    let(:staff_profile) { FactoryBot.create :staff_profile, user: user }
    before do
      staff_profile
      sign_in user
    end

    describe "GET /departments" do
      it "works! (now write some real specs)" do
        get departments_path
        expect(response).to have_http_status(200)
      end
    end
  end

  context "Public user" do
    it "fails to allow acces to page" do
      get departments_path
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
