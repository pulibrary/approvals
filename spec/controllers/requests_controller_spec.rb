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
  let(:other_travel) { FactoryBot.create(:travel_request) }
  let(:my_absence) { FactoryBot.create(:absence_request, creator: staff_profile) }
  let(:my_travel) { FactoryBot.create(:travel_request, creator: staff_profile) }

  before do
    sign_in user
  end

  describe "GET #my_requests" do
    before do
      # create all the requests
      other_absence
      other_travel
      my_absence
      my_travel
    end
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

    it "accepts limit by status" do
      approved_absence = FactoryBot.create(:absence_request, status: "approved", creator: staff_profile)
      get :my_requests, params: { filters: { status: "approved" } }, session: valid_session
      expect(assigns(:requests)).to contain_exactly(approved_absence)
    end

    it "accepts limit by request type absence" do
      get :my_requests, params: { filters: { request_type: "absence" } }, session: valid_session
      expect(assigns(:requests)).to contain_exactly(my_absence)
    end

    it "accepts limit by request type sick" do
      my_sick_absence = FactoryBot.create(:absence_request, creator: staff_profile, absence_type: "sick")
      get :my_requests, params: { filters: { request_type: "sick" } }, session: valid_session
      expect(assigns(:requests)).to contain_exactly(my_sick_absence)
    end

    it "accepts limit by request type travel" do
      get :my_requests, params: { filters: { request_type: "travel" } }, session: valid_session
      expect(assigns(:requests)).to contain_exactly(my_travel)
    end

    it "accepts limit by request type business" do
      my_business_travel = FactoryBot.create(:travel_request, creator: staff_profile, travel_category: "business")
      get :my_requests, params: { filters: { request_type: "business" } }, session: valid_session
      expect(assigns(:requests)).to contain_exactly(my_business_travel)
    end

    it "accepts limit by status and request type" do
      my_business_travel = FactoryBot.create(:travel_request, creator: staff_profile, status: "approved", travel_category: "business")
      FactoryBot.create(:travel_request, creator: staff_profile, status: "approved", travel_category: "discretionary")
      get :my_requests, params: { filters: { request_type: "business", status: "approved" } }, session: valid_session
      expect(assigns(:requests)).to contain_exactly(my_business_travel)
    end
  end

  describe "GET #my_requests with sort params" do
    let(:yesterday) { Time.zone.yesterday }
    let(:today) { Time.zone.today }
    let(:tomorrow) { Time.zone.tomorrow }
    # r1: created yesterday, modified tomorrow, start date today
    let(:r1) do
      Timecop.freeze(yesterday) do
        FactoryBot.create(:travel_request, creator: staff_profile, start_date: today)
      end
    end
    # r2: created today, modified yesterday, start date tomorrow
    let(:r2) do
      Timecop.freeze(today) do
        FactoryBot.create(:travel_request, creator: staff_profile, start_date: tomorrow)
      end
    end
    # r3: created tomorrow, modified today, start date yesterday
    let(:r3) do
      Timecop.freeze(tomorrow) do
        FactoryBot.create(:travel_request, creator: staff_profile, start_date: yesterday)
      end
    end

    before do
      yesterday
      today
      tomorrow
      Timecop.freeze(yesterday) do
        r2.status = "approved"
        r2.save
      end
      r3.status = "approved"
      r3.save
      Timecop.freeze(tomorrow) do
        r1.status = "approved"
        r1.save
      end
    end

    context "sort by start date" do
      it "by default sorts by start date descending" do
        get :my_requests, session: valid_session
        expect(assigns(:requests).map(&:id)).to eq [r2, r1, r3].map(&:id)
      end

      it "sorts ascending" do
        get :my_requests, params: { sort: "start_date_asc" }, session: valid_session
        expect(assigns(:requests).map(&:id)).to eq [r3, r1, r2].map(&:id)
      end
    end

    context "sort by date created" do
      it "sorts ascending" do
        get :my_requests, params: { sort: "created_at_asc" }, session: valid_session
        expect(assigns(:requests).map(&:id)).to eq [r1, r2, r3].map(&:id)
      end

      it "sorts descending" do
        get :my_requests, params: { sort: "created_at_desc" }, session: valid_session
        expect(assigns(:requests).map(&:id)).to eq [r3, r2, r1].map(&:id)
      end
    end

    context "sort by date modified" do
      it "sorts ascending" do
        get :my_requests, params: { sort: "updated_at_asc" }, session: valid_session
        expect(assigns(:requests).map(&:id)).to eq [r2, r3, r1].map(&:id)
      end

      it "sorts descending" do
        get :my_requests, params: { sort: "updated_at_desc" }, session: valid_session
        expect(assigns(:requests).map(&:id)).to eq [r1, r3, r2].map(&:id)
      end
    end
  end
end
