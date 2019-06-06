require "rails_helper"

RSpec.describe RequestsController, type: :controller do
  let(:creator) { FactoryBot.create(:staff_profile) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AbsenceRequestsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:user) { FactoryBot.create :user }

  before do
    sign_in user
  end

  describe "GET #my_requests" do
    it "returns a success response" do
      FactoryBot.create(:absence_request)
      FactoryBot.create(:travel_request)
      get :my_requests, params: {}, session: valid_session
      expect(response).to be_successful
      expect(assigns(:requests)).to eq Request.all
    end

    it "returns a success response as json" do
      FactoryBot.create(:absence_request)
      FactoryBot.create(:travel_request)
      get :my_requests, params: { format: :json }, session: valid_session
      expect(response).to be_successful
      expect(assigns(:requests)).to eq Request.all
    end
  end
end
