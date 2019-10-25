# frozen_string_literal: true
require "rails_helper"

RSpec.describe "RecurringEvents", type: :request do
  describe "GET /recurring_events" do
    context "Signed in user" do
      let(:user) { FactoryBot.create :user }
      let(:staff_profile) { FactoryBot.create :staff_profile, user: user }
      before do
        staff_profile
        sign_in user
      end

      it "works! (now write some real specs)" do
        get recurring_events_path
        expect(response).to have_http_status(200)
      end
    end

    context "Public user" do
      it "fails to allow acces to page" do
        get recurring_events_path
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
