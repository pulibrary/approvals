# frozen_string_literal: true

require "rails_helper"

RSpec.describe RequestsController, type: :controller do
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AbsenceRequestsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:user) { create(:user) }
  let(:staff_profile) { create(:staff_profile, :with_department, user:) }

  let(:other_absence) { create(:absence_request) }
  let(:other_travel) { create(:travel_request) }
  let(:my_absence) { create(:absence_request, creator: staff_profile, start_date: Time.zone.tomorrow) }
  let(:my_travel) { create(:travel_request, creator: staff_profile) }

  before do
    sign_in user
  end

  after do
    Kaminari.config.default_per_page = 25
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
      expect(assigns(:requests).first).to be_a TravelRequestDecorator
      expect(assigns(:requests).last).to be_a AbsenceRequestDecorator
      expect(assigns(:requests).map(&:id)).to contain_exactly(*[my_absence, my_travel].map(&:id))
    end

    it "returns a success response as json" do
      get :my_requests, params: { format: :json }, session: valid_session
      expect(response).to be_successful
      expect(assigns(:requests).map(&:id)).to contain_exactly(*[my_absence, my_travel].map(&:id))
    end

    it "accepts paging" do
      Kaminari.config.default_per_page = 1
      get :my_requests, params: { format: :json, page: 2 }, session: valid_session
      expect(response).to be_successful
      expect(assigns(:requests).map(&:id)).to contain_exactly(my_absence.id)
    end

    it "accepts limit by status" do
      approved_absence = create(:absence_request, action: :approve, creator: staff_profile)
      get :my_requests, params: { filters: { status: "approved" } }, session: valid_session
      expect(assigns(:requests).map(&:id)).to contain_exactly(approved_absence.id)
    end

    it "accepts limit by request type absence" do
      get :my_requests, params: { filters: { request_type: "absence" } }, session: valid_session
      expect(assigns(:requests).map(&:id)).to contain_exactly(my_absence.id)
    end

    it "accepts limit by request type sick" do
      my_sick_absence = create(:absence_request, creator: staff_profile, absence_type: "sick")
      get :my_requests, params: { filters: { request_type: "sick" } }, session: valid_session
      expect(assigns(:requests).map(&:id)).to contain_exactly(my_sick_absence.id)
    end

    it "accepts limit by request type travel" do
      get :my_requests, params: { filters: { request_type: "travel" } }, session: valid_session
      expect(assigns(:requests).map(&:id)).to contain_exactly(my_travel.id)
    end

    it "accepts limit by request type business" do
      my_business_travel = create(:travel_request, creator: staff_profile, travel_category: "business")
      get :my_requests, params: { filters: { request_type: "business" } }, session: valid_session
      expect(assigns(:requests).map(&:id)).to contain_exactly(my_business_travel.id)
    end

    it "accepts limit by status and request type" do
      my_business_travel = create(:travel_request, creator: staff_profile, action: "approve",
                                                   travel_category: "business")
      create(:travel_request, creator: staff_profile, action: "approve",
                              travel_category: "professional_development")
      get :my_requests, params: { filters: { request_type: "business", status: "approved" } }, session: valid_session
      expect(assigns(:requests).map(&:id)).to contain_exactly(my_business_travel.id)
    end
  end

  describe "GET #my_approval_requests" do
    let(:profile) { create(:staff_profile, supervisor: staff_profile) }
    let(:approval_absence) { create(:absence_request, creator: profile, start_date: Time.zone.tomorrow) }
    let(:approval_travel) { create(:travel_request, creator: profile, start_date: Time.zone.now) }

    before do
      # create all the requests
      other_absence
      other_travel
      my_absence
      my_travel
      approval_absence
      approval_travel
    end

    it "returns a success response" do
      get :my_approval_requests, params: {}, session: valid_session
      expect(response).to be_successful
      expect(assigns(:requests).first).to be_a TravelRequestDecorator
      expect(assigns(:requests).last).to be_a AbsenceRequestDecorator
      expect(assigns(:requests).map(&:id)).to contain_exactly(*[approval_absence, approval_travel].map(&:id))
    end

    it "accepts page information" do
      Kaminari.config.default_per_page = 1
      get :my_approval_requests, params: { page: 2 }, session: valid_session
      expect(response).to be_successful
      expect(assigns(:requests).first).to be_a AbsenceRequestDecorator
      expect(assigns(:requests).map(&:id)).to contain_exactly(approval_absence.id)
    end

    it "runs reasonably fast" do
      30.times do
        create(:absence_request, creator: profile, start_date: Time.zone.tomorrow)
        create(:travel_request, creator: profile)
      end
      100.times do
        create(:absence_request, start_date: Time.zone.tomorrow)
        create(:travel_request)
      end
      start_time = Time.zone.now
      10.times do
        get :my_approval_requests, params: {}, session: valid_session
      end
      end_time = Time.zone.now

      expect(response).to be_successful
      expect((end_time - start_time) < 4).to be_truthy
    end

    it "returns a success response as json" do
      get :my_approval_requests, params: { format: :json }, session: valid_session
      expect(response).to be_successful
      expect(assigns(:requests).map(&:id)).to contain_exactly(*[approval_absence, approval_travel].map(&:id))
    end

    it "accepts limit by request type absence" do
      get :my_approval_requests, params: { filters: { request_type: "absence" } }, session: valid_session
      expect(assigns(:requests).map(&:id)).to contain_exactly(approval_absence.id)
    end

    context "shows when changes are requested by the current supervisor" do
      let(:profile1) { create(:staff_profile, supervisor: profile2) }
      let(:profile2) { create(:staff_profile, supervisor: staff_profile) }
      let(:approval_absence) { create(:absence_request, creator: profile1, start_date: Time.zone.tomorrow) }
      let(:approval_travel) { create(:travel_request, creator: profile1, start_date: Time.zone.now) }

      before do
        approval_absence.approve(agent: profile2)
        approval_travel.approve(agent: profile2)
        approval_travel.change_request(agent: staff_profile)
        approval_travel.fix_requested_changes!(agent: profile1)
      end

      it "returns a success response" do
        get :my_approval_requests, params: {}, session: valid_session
        expect(response).to be_successful
        expect(assigns(:requests).first).to be_a TravelRequestDecorator
        expect(assigns(:requests).last).to be_a AbsenceRequestDecorator
        expect(assigns(:requests).map(&:id)).to contain_exactly(*[approval_absence, approval_travel].map(&:id))
      end
    end
  end

  describe "GET #reports" do
    let(:supervisor) { create(:staff_profile, user:) }
    let(:staff_profile) { create(:staff_profile, supervisor:, biweekly: true) }
    let(:supervisor_absence) do
 create(:absence_request, creator: supervisor, start_date: Time.zone.tomorrow)
    end

    before do
      # create all the requests
      other_absence
      other_travel
      my_absence
      my_travel
      supervisor_absence
    end

    it "returns a success response" do
      get :reports, params: {}, session: valid_session
      expect(response).to be_successful
      expect(assigns(:requests).map(&:id)).to contain_exactly(*[my_travel, my_absence, supervisor_absence].map(&:id))
    end

    it "filters based on employee type" do
      get :reports, params: { filters: { employee_type: "biweekly" } }, session: valid_session
      expect(response).to be_successful
      expect(assigns(:requests).map(&:id)).to contain_exactly(*[my_travel, my_absence].map(&:id))
    end

    it "filters based on supervisor" do
      sub_staff = create(:staff_profile, supervisor: staff_profile, department: supervisor.department)
      sub_absence = create(:absence_request, creator: sub_staff)
      sub_travel = create(:travel_request, creator: sub_staff)
      get :reports, params: { filters: { supervisor: staff_profile.id } }, session: valid_session
      expect(response).to be_successful
      expect(assigns(:requests).map(&:id)).to contain_exactly(*[my_travel, my_absence, sub_absence,
                                                                sub_travel].map(&:id))
    end
  end

  describe "GET #my_requests with sort params" do
    let(:yesterday) { Time.zone.yesterday }
    let(:today) { Time.zone.today }
    let(:tomorrow) { Time.zone.tomorrow }
    # r1: created yesterday, modified tomorrow, start date today
    let(:r1) do
      Timecop.freeze(yesterday) do
        create(:travel_request, creator: staff_profile, start_date: today)
      end
    end
    # r2: created today, modified yesterday, start date tomorrow
    let(:r2) do
      Timecop.freeze(today) do
        create(:travel_request, creator: staff_profile, start_date: tomorrow)
      end
    end
    # r3: created tomorrow, modified today, start date yesterday
    let(:r3) do
      Timecop.freeze(tomorrow) do
        create(:travel_request, creator: staff_profile, start_date: yesterday)
      end
    end

    before do
      yesterday
      today
      tomorrow
      Timecop.freeze(yesterday) do
        r2.approve!(agent: staff_profile.department.head)
      end
      r3.approve!(agent: staff_profile.department.head)
      Timecop.freeze(tomorrow) do
        r1.approve!(agent: staff_profile.department.head)
      end
    end

    it "by default sorts by updated date ascending" do
      get :my_requests, session: valid_session
      expect(assigns(:requests).map(&:id)).to eq [r1, r3, r2].map(&:id)
    end

    context "sort by start date" do
      it "sorts ascending" do
        get :my_requests, params: { sort: "start_date_asc" }, session: valid_session
        expect(assigns(:requests).map(&:id)).to eq [r3, r1, r2].map(&:id)
      end

      it "sorts descending" do
        get :my_requests, params: { sort: "start_date_desc" }, session: valid_session
        expect(assigns(:requests).map(&:id)).to eq [r2, r1, r3].map(&:id)
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

  describe "GET #my_requests with searching" do
    it "retrieves a result" do
      absence_request = create(:absence_request, creator: staff_profile, action: :approve)
      absence_request2 = create(:absence_request, creator: staff_profile, action: :deny)
      travel_request = create(:travel_request, creator: staff_profile)
      create(:note, content: "elephants love balloons", request: absence_request)
      create(:note, content: "elephants love balloons", request: absence_request2)
      create(:note, content: "flamingoes are pink because of shrimp", request: travel_request)

      get :my_requests, params: { query: "balloons", filters: { status: :approved } }, session: valid_session
      expect(assigns(:requests).count).to eq 1
    end
  end

  describe "GET #my_approval_requests with searching" do
    it "retrieves a result" do
      profile = create(:staff_profile, supervisor: staff_profile, given_name: "Haley")
      absence_request = create(:absence_request, creator: profile)
      absence_request2 = create(:absence_request, creator: profile)
      travel_request = create(:travel_request, creator: profile)
      create(:note, content: "elephants love balloons", request: absence_request)
      create(:note, content: "elephants love pink balloons", request: absence_request2)
      create(:note, content: "flamingoes are pink because of shrimp", request: travel_request)

      get :my_approval_requests, params: { query: "balloons" }, session: valid_session
      expect(assigns(:requests).count).to eq 2

      get :my_approval_requests, params: { query: "haley", filters: { request_type: :travel } }, session: valid_session
      expect(assigns(:requests).count).to eq 1
    end
  end

  context "filter by date range" do
    # using let! to make sure the requests exist
    let!(:r1) { create(:travel_request, creator:, start_date: today, end_date: today) }
    let!(:r2) { create(:travel_request, creator:, start_date: tomorrow, end_date: tomorrow) }
    let!(:r3) { create(:travel_request, creator:, start_date: yesterday, end_date: yesterday) }
    let!(:r4) { create(:travel_request, creator:, start_date: today, end_date: tomorrow) }
    let!(:r5) { create(:travel_request, creator:, start_date: yesterday, end_date: today) }

        describe "GET #my_requests" do
      let(:creator) { staff_profile }
      let(:day_before_yesterday) { Time.zone.yesterday.yesterday }
      let(:yesterday) { Time.zone.yesterday }
      let(:today) { Time.zone.today }
      let(:tomorrow) { Time.zone.tomorrow }
      let(:day_after_tomorrow) { Time.zone.tomorrow.tomorrow }

      it "retrieves the results from yesterday" do
        get :my_requests,
            params: { filters: { date: "#{yesterday.strftime('%m/%d/%Y')} - #{yesterday.strftime('%m/%d/%Y')}" } }, session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r5.id, r3.id]
      end

      it "retrieves the results from yesterday when start does not match, but end does" do
        get :my_requests,
            params: { sort: "created_at_asc", filters: { date: "#{day_before_yesterday.strftime('%m/%d/%Y')} - #{yesterday.strftime('%m/%d/%Y')}" } }, session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r3.id, r5.id]
      end

      it "retrieves the results from today" do
        get :my_requests,
            params: { filters: { date: "#{today.strftime('%m/%d/%Y')} - #{today.strftime('%m/%d/%Y')}" } }, session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r5.id, r4.id, r1.id]
      end

      it "retrieves the results from yesterday and today" do
        get :my_requests,
            params: { filters: { date: "#{yesterday.strftime('%m/%d/%Y')} - #{today.strftime('%m/%d/%Y')}" } }, session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r5.id, r4.id, r3.id, r1.id]
      end

      it "retrieves the results from a wider range" do
        get :my_requests,
            params: { filters: { date: "#{day_before_yesterday.strftime('%m/%d/%Y')} - #{day_after_tomorrow.strftime('%m/%d/%Y')}" } }, session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r5.id, r4.id, r3.id, r2.id, r1.id]
      end
        end

    describe "GET #my_approval_requests" do
      let(:creator) { profile }
      let(:profile) { create(:staff_profile, supervisor: staff_profile, given_name: "Haley") }
      let(:day_before_yesterday) { Time.zone.yesterday.yesterday }
      let(:yesterday) { Time.zone.yesterday }
      let(:today) { Time.zone.today }
      let(:tomorrow) { Time.zone.tomorrow }
      let(:day_after_tomorrow) { Time.zone.tomorrow.tomorrow }

      it "retrieves the results from yesterday" do
        get :my_approval_requests,
            params: { sort: "created_at_asc", filters: { date: "#{yesterday.strftime('%m/%d/%Y')} - #{yesterday.strftime('%m/%d/%Y')}" } }, session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r3.id, r5.id]
      end

      it "retrieves the results from yesterday when start does not match, but end does" do
        get :my_approval_requests,
            params: { sort: "created_at_asc", filters: { date: "#{day_before_yesterday.strftime('%m/%d/%Y')} - #{yesterday.strftime('%m/%d/%Y')}" } }, session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r3.id, r5.id]
      end

      it "retrieves the results from today" do
        get :my_approval_requests,
            params: { sort: "created_at_asc", filters: { date: "#{today.strftime('%m/%d/%Y')} - #{today.strftime('%m/%d/%Y')}" } }, session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r1.id, r4.id, r5.id]
      end

      it "retrieves the results from yesterday and today" do
        get :my_approval_requests,
            params: { sort: "created_at_asc", filters: { date: "#{yesterday.strftime('%m/%d/%Y')} - #{today.strftime('%m/%d/%Y')}" } }, session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r1.id, r3.id, r4.id, r5.id]
      end

      it "retrieves the results from a wider range" do
        get :my_approval_requests, params: { sort: "created_at_asc",
                                             filters: { date: "#{day_before_yesterday.strftime('%m/%d/%Y')} - #{day_after_tomorrow.strftime('%m/%d/%Y')}" } },
                                   session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r1.id, r2.id, r3.id, r4.id, r5.id]
      end
    end

    describe "GET #reports" do
      let(:creator) { profile }
      let(:profile) { create(:staff_profile, supervisor: staff_profile, given_name: "Haley") }
      let(:day_before_yesterday) { Time.zone.yesterday.yesterday }
      let(:yesterday) { Time.zone.yesterday }
      let(:today) { Time.zone.today }
      let(:tomorrow) { Time.zone.tomorrow }
      let(:day_after_tomorrow) { Time.zone.tomorrow.tomorrow }

      it "retrieves the results from yesterday" do
        get :reports,
            params: { sort: "created_at_asc", filters: { date: "#{yesterday.strftime('%m/%d/%Y')} - #{yesterday.strftime('%m/%d/%Y')}" } }, session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r3.id, r5.id]
      end

      it "retrieves the results from yesterday when start does not match, but end does" do
        get :reports,
            params: { sort: "created_at_asc", filters: { date: "#{day_before_yesterday.strftime('%m/%d/%Y')} - #{yesterday.strftime('%m/%d/%Y')}" } }, session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r3.id, r5.id]
      end

      it "retrieves the results from today" do
        get :reports,
            params: { sort: "created_at_asc", filters: { date: "#{today.strftime('%m/%d/%Y')} - #{today.strftime('%m/%d/%Y')}" } }, session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r1.id, r4.id, r5.id]
      end

      it "retrieves the results from yesterday and today" do
        get :reports,
            params: { sort: "created_at_asc", filters: { date: "#{yesterday.strftime('%m/%d/%Y')} - #{today.strftime('%m/%d/%Y')}" } }, session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r1.id, r3.id, r4.id, r5.id]
      end

      it "retrieves the results from a wider range" do
        get :reports, params: { sort: "created_at_asc",
                                filters: { date: "#{day_before_yesterday.strftime('%m/%d/%Y')} - #{day_after_tomorrow.strftime('%m/%d/%Y')}" } },
                      session: valid_session
        expect(assigns(:requests).request_list.map(&:id)).to eq [r1.id, r2.id, r3.id, r4.id, r5.id]
      end
    end
  end
end
