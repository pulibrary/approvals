# frozen_string_literal: true
require "rails_helper"

RSpec.describe "StateChanges", type: :request do
  context "Signed in user" do
    let(:user) { FactoryBot.create :user }
    before do
      sign_in user
    end

    describe "GET /state_changes" do
      it "allows access" do
        get state_changes_path
        expect(response).to have_http_status(200)
      end
    end
  end

  context "Public user" do
    it "fails to allow access to page" do
      get state_changes_path
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
