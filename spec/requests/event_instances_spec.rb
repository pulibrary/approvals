require "rails_helper"

RSpec.describe "EventInstances", type: :request do
  describe "GET /event_instances" do
    context "Signed in user" do
      let(:user) { FactoryBot.create :user }
      before do
        sign_in user
      end

      it "works! (now write some real specs)" do
        get event_instances_path
        expect(response).to have_http_status(200)
      end
    end

    context "Public user" do
      it "fails to allow acces to page" do
        get event_instances_path
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
