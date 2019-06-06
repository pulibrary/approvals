require "rails_helper"

RSpec.describe RequestsController, type: :controller do
  let(:creator) { FactoryBot.create(:staff_profile) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AbsenceRequestsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:user) { FactoryBot.create :user }
  let(:staff_profile) { FactoryBot.create :staff_profile, user: user }
  let(:other_absence) { FactoryBot.create(:absence_request) }
  let(:other_travel)  { FactoryBot.create(:travel_request) }
  let(:my_absence)    { FactoryBot.create(:absence_request, creator: staff_profile) }
  let(:my_travel)     { FactoryBot.create(:travel_request, creator: staff_profile) }

  before do
    sign_in user

    # create all the requests
    other_absence; other_travel; my_absence; my_travel
  end

  describe "GET #my_requests" do
    it "returns a success response" do
      get :my_requests, params: {}, session: valid_session
      expect(response).to be_successful
      expect(assigns(:requests)).to contain_exactly(my_absence, my_travel)
    end

    it "returns a success response as json" do
      get :my_requests, params: { format: :json }, session: valid_session
      expect(response).to be_successful
      expect(assigns(:requests)).to contain_exactly(my_absence, my_travel)
    end
  end
end
