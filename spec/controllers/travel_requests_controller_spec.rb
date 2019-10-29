# frozen_string_literal: true
require "rails_helper"

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

RSpec.describe TravelRequestsController, type: :controller do
  let(:recurring_event) { FactoryBot.create(:recurring_event, name: "Ice Capades") }
  let(:creator) { FactoryBot.create(:staff_profile, :with_department, user: user) }
  let(:start_date) { Time.zone.today }
  let(:end_date) { Time.zone.tomorrow }
  # This should return the minimal set of attributes required to create a valid
  # TravelRequest. As you add validations to TravelRequest, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      creator_id: creator.id,
      start_date: start_date,
      end_date: end_date,
      request_type: "TravelRequest",
      purpose: "Travel to campus for in-person meetings",
      participation: "member",
      event_requests: [
        recurring_event_id: recurring_event.id,
        location: "Mumbai",
        event_dates: "#{Time.zone.yesterday.strftime('%m/%d/%Y')} - #{Time.zone.today.strftime('%m/%d/%Y')}"
      ],
      travel_category: "business", # note this field is not available on the create form; only on approval.
    }
  end

  let(:invalid_attributes) do
    { participation: "" }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TravelRequestsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:user) { FactoryBot.create :user }

  before do
    sign_in user
    creator # call this now so the staff profile for the signed in user is always created
  end

  describe "GET #show" do
    it "returns a success response" do
      travel_request = FactoryBot.create(:travel_request)
      get :show, params: { id: travel_request.to_param }, session: valid_session
      expect(response).to be_successful
      assert_equal travel_request, assigns(:request).to_model
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
      request_change_set = assigns(:request_change_set)
      expect(request_change_set).to be_a(TravelRequestChangeSet)
      expect(request_change_set.event_requests[0].model.start_date).to eq(Time.zone.today.to_date)
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      travel_request = FactoryBot.create(:travel_request)
      get :edit, params: { id: travel_request.to_param }, session: valid_session
      expect(response).to be_successful
      expect(assigns(:request_change_set)).to be_a(TravelRequestChangeSet)
      assert_equal travel_request, assigns(:request_change_set).model
    end

    it "can edit a changes_requested request" do
      travel_request = FactoryBot.create(:travel_request, action: "change_request")
      get :edit, params: { id: travel_request.to_param }, session: valid_session
      expect(response).to be_successful
      expect(assigns(:request_change_set)).to be_a(TravelRequestChangeSet)
      assert_equal travel_request, assigns(:request_change_set).model
    end

    it "can not edit an approved request" do
      travel_request = FactoryBot.create(:travel_request, action: "approve")
      get :edit, params: { id: travel_request.to_param }, session: valid_session
      expect(response).to redirect_to(travel_request)
      expect(assigns(:request)).to eq(travel_request)
    end

    it "can not edit a denied request" do
      travel_request = FactoryBot.create(:travel_request, action: "deny")
      get :edit, params: { id: travel_request.to_param }, session: valid_session
      expect(response).to redirect_to(travel_request)
      expect(assigns(:request)).to eq(travel_request)
    end

    it "can not edit a canceled request" do
      travel_request = FactoryBot.create(:travel_request, action: "cancel")
      get :edit, params: { id: travel_request.to_param }, session: valid_session
      expect(response).to redirect_to(travel_request)
      expect(assigns(:request)).to eq(travel_request)
    end
  end

  describe "GET #review" do
    it "returns a success response" do
      staff_profile = FactoryBot.create :staff_profile, supervisor: creator
      travel_request = FactoryBot.create(:travel_request, creator: staff_profile)
      get :review, params: { id: travel_request.to_param }, session: valid_session
      expect(response).to be_successful
      expect(assigns(:request_change_set)).to be_a TravelRequestChangeSet
    end

    it "does not allow the creator to review" do
      travel_request = FactoryBot.create(:travel_request, creator: creator)
      get :review, params: { id: travel_request.to_param }, session: valid_session
      expect(response).to redirect_to(travel_request)
      expect(assigns(:request)).to eq(travel_request)
    end

    it "Does not allow review after denied" do
      staff_profile = FactoryBot.create :staff_profile, supervisor: creator, department: creator.department
      travel_request = FactoryBot.create(:travel_request, creator: staff_profile, action: "deny")
      get :review, params: { id: travel_request.to_param }, session: valid_session
      expect(response).to redirect_to(travel_request)
      expect(assigns(:request)).to eq(travel_request)
    end

    it "Does not allow review after cancel" do
      staff_profile = FactoryBot.create :staff_profile, supervisor: creator, department: creator.department
      travel_request = FactoryBot.create(:travel_request, creator: staff_profile, action: "cancel")
      get :review, params: { id: travel_request.to_param }, session: valid_session
      expect(response).to redirect_to(travel_request)
      expect(assigns(:request)).to eq(travel_request)
    end

    it "Does not allow review after change_request" do
      staff_profile = FactoryBot.create :staff_profile, supervisor: creator, department: creator.department
      travel_request = FactoryBot.create(:travel_request, creator: staff_profile, action: "change_request")
      get :review, params: { id: travel_request.to_param }, session: valid_session
      expect(response).to redirect_to(travel_request)
      expect(assigns(:request)).to eq(travel_request)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new TravelRequest" do
        expect do
          post :create, params: { travel_request: valid_attributes }, session: valid_session
        end.to change(TravelRequest, :count).by(1)
        updated = TravelRequest.last
        expect(updated.start_date).to eq start_date
        expect(updated.end_date).to eq end_date
        expect(updated.purpose).to eq "Travel to campus for in-person meetings"
        expect(updated.participation).to eq "member"
        expect(updated.recurring_events.count).to eq 1
        expect(updated.event_title).to eq "Ice Capades #{Time.zone.today.year}, Mumbai"
      end

      it "redirects to the created travel_request" do
        post :create, params: { travel_request: valid_attributes }, session: valid_session
        expect(response).to redirect_to(TravelRequest.last)
        assert_equal TravelRequest.last, assigns(:request)
      end
    end

    context "with fre text event" do
      let(:valid_attributes) do
        {
          creator_id: creator.id,
          start_date: start_date,
          end_date: end_date,
          request_type: "TravelRequest",
          purpose: "Travel to campus for in-person meetings",
          participation: "member",
          event_requests: [
            recurring_event_id: "A new event",
            location: "Mumbai",
            event_dates: "#{Time.zone.yesterday.strftime('%m/%d/%Y')} - #{Time.zone.today.strftime('%m/%d/%Y')}"
          ],
          travel_category: "business", # note this field is not available on the create form; only on approval.
        }
      end

      it "redirects to the created travel_request" do
        post :create, params: { travel_request: valid_attributes }, session: valid_session
        expect(response).to redirect_to(TravelRequest.last)
        assert_equal TravelRequest.last, assigns(:request)
      end
    end
    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { travel_request: invalid_attributes }, session: valid_session
        expect(response).to be_successful
        expect(assigns(:request_change_set)).to be_a(TravelRequestChangeSet)
        expect(assigns(:request_change_set).errors.messages).to eq(event_requests: ["can't be blank"],
                                                                   participation: ["is not included in the list"],
                                                                   purpose: ["can't be blank"])
      end
    end
  end

  describe "PUT #update" do
    context "with valid nested attributes" do
      let(:recurring_event) { FactoryBot.create :recurring_event, name: "Conference" }
      let(:nested_attributes) do
        {
          notes: [{ creator_id: creator.id, content: "Important message" }],
          estimates: [amount: 200.20, recurrence: 3, cost_type: "lodging"],
          event_requests: [{ start_date: start_date, location: "Paris", recurring_event_id: recurring_event.id }]
        }
      end

      it "updates the requested travel_request" do
        travel_request = FactoryBot.create(:travel_request)
        put :update, params: { id: travel_request.to_param, travel_request: nested_attributes }, session: valid_session
        travel_request.reload
        expect(travel_request.notes.last.content).to eq "Important message"
        expect(travel_request.estimates.last.amount).to eq 200.20
        expect(travel_request.event_requests.count).to eq 1
        expect(travel_request.event_requests[0].recurring_event.name).to eq "Conference"
        expect(travel_request.event_requests[0].start_date).to eq start_date
        expect(travel_request.event_requests[0].location).to eq "Paris"
      end

      context "with estimate that will be updated" do
        let(:recurring_event) { FactoryBot.create :recurring_event, name: "Conference" }
        let(:travel_request) { FactoryBot.create(:travel_request, :with_note_and_estimate) }
        let(:nested_attributes) do
          {
            notes: [{ creator_id: creator.id, content: "Important message" }],
            estimates: [id: travel_request.estimates[0].id, amount: 200.20, recurrence: 3, cost_type: "lodging"],
            event_requests: [{ start_date: start_date, location: "Paris", recurring_event_id: recurring_event.id }]
          }
        end

        it "updates the requested travel_request" do
          put :update, params: { id: travel_request.to_param, travel_request: nested_attributes }, session: valid_session
          travel_request.reload
          expect(travel_request.notes.last.content).to eq "Important message"
          expect(travel_request.estimates.last.amount).to eq 200.20
          expect(travel_request.event_requests.count).to eq 1
          expect(travel_request.event_requests[0].recurring_event.name).to eq "Conference"
          expect(travel_request.event_requests[0].start_date).to eq start_date
          expect(travel_request.event_requests[0].location).to eq "Paris"
        end
      end

      it "redirects to the travel_request" do
        travel_request = FactoryBot.create(:travel_request)
        put :update, params: { id: travel_request.to_param, travel_request: nested_attributes }, session: valid_session
        expect(response).to redirect_to(travel_request)
        expect(assigns(:request)).to be_a(TravelRequest)
      end

      # rubocop:disable RSpec/AnyInstance
      context "invalid save to database" do
        let(:travel_request) { FactoryBot.create(:travel_request) }
        before do
          travel_request
          allow_any_instance_of(TravelRequest).to receive(:save).and_return(false)
          bad_note = Note.new(creator_id: 123)
          bad_note.save
          allow_any_instance_of(TravelRequest).to receive(:errors).and_return(bad_note.errors)
        end

        it "returns a success response (i.e. to display the 'new' template)" do
          put :update, params: { id: travel_request.to_param, travel_request: valid_attributes }, session: valid_session
          expect(response).to be_successful
          expect(assigns(:request_change_set).errors.messages).to eq(request: ["must exist"], creator: ["must exist"])
        end

        it "returns json with errors" do
          put :update, params: { id: travel_request.to_param, travel_request: valid_attributes, format: :json }, session: valid_session
          expect(response).not_to be_successful
          expect(response.media_type).to eq("application/json")
          expect(response.body).to eq('{"request":["must exist"],"creator":["must exist"]}')
        end
      end
    end

    context "with invalid note params" do
      let(:invalid_nested_attributes) do
        {
          notes: [{ content: nil }]
        }
      end

      it "returns a success response (i.e. to display the 'edit' template)" do
        travel_request = FactoryBot.create(:travel_request)
        expect do
          put :update, params: { id: travel_request.to_param, travel_request: invalid_nested_attributes }, session: valid_session
          expect(response).to redirect_to(travel_request)
        end.to change(Note, :count).by(0)
      end
    end

    context "with invalid event_request params" do
      let(:invalid_nested_attributes) do
        {
          event_requests: [{ recurring_event_id: recurring_event.id }]
        }
      end

      it "returns a success response (i.e. to display the 'edit' template)" do
        travel_request = FactoryBot.create(:travel_request)
        put :update, params: { id: travel_request.to_param, travel_request: invalid_nested_attributes }, session: valid_session
        expect(assigns(:request_change_set).event_requests.last.recurring_event_id).to eq recurring_event.id.to_s
      end
    end
  end

  describe "Put #approve" do
    it "does not fully approve for a supervisor and adds a note" do
      staff_profile = FactoryBot.create :staff_profile, supervisor: creator
      travel_request = FactoryBot.create(:travel_request, creator: staff_profile)
      notes = { notes: [{ content: "Important message" }] }
      put :approve, params: { id: travel_request.to_param, travel_request: notes }, session: valid_session
      travel_request.reload
      expect(travel_request.notes.count).to eq 1
      expect(travel_request).not_to be_approved
      expect(travel_request.state_changes.map(&:action)).to eq ["approved"]
    end

    it "fully approves for a department head and adds a note" do
      staff_profile = FactoryBot.create :staff_profile, supervisor: creator
      staff_profile.department.head = creator
      staff_profile.department.save
      travel_request = FactoryBot.create(:travel_request, creator: staff_profile)
      notes = { notes: [{ content: "Important message" }] }
      put :approve, params: { id: travel_request.to_param, travel_request: notes }, session: valid_session
      travel_request.reload
      expect(travel_request.notes.count).to eq 1
      expect(travel_request).to be_approved
    end

    it "does not allow the creator to approve" do
      travel_request = FactoryBot.create(:travel_request, creator: creator)
      notes = { notes: [{ content: "Important message" }] }
      put :approve, params: { id: travel_request.to_param, travel_request: notes }, session: valid_session
      expect(response).to redirect_to(travel_request)
      expect(assigns(:request)).to eq(travel_request)
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'review' template)" do
        staff_profile = FactoryBot.create :staff_profile, supervisor: creator
        travel_request = FactoryBot.create(:travel_request, creator: staff_profile)
        put :approve, params: { id: travel_request.to_param, travel_request: invalid_attributes }, session: valid_session
        expect(response).to be_successful
        expect(assigns(:request_change_set).errors.messages).to eq(participation: ["is not included in the list"])
      end
    end
  end

  describe "Put #deny" do
    it "returns a success response" do
      staff_profile = FactoryBot.create :staff_profile, supervisor: creator
      travel_request = FactoryBot.create(:travel_request, creator: staff_profile)
      notes = { notes: [{ content: "Important message" }] }
      put :deny, params: { id: travel_request.to_param, travel_request: notes }, session: valid_session
      travel_request.reload
      expect(travel_request.notes.count).to eq 1
      expect(travel_request).to be_denied
    end

    it "does not allow the creator to deny" do
      travel_request = FactoryBot.create(:travel_request, creator: creator)
      notes = { notes: [{ content: "Important message" }] }
      put :deny, params: { id: travel_request.to_param, travel_request: notes }, session: valid_session
      expect(response).to redirect_to(travel_request)
      expect(assigns(:request)).to eq(travel_request)
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'review' template)" do
        staff_profile = FactoryBot.create :staff_profile, supervisor: creator
        travel_request = FactoryBot.create(:travel_request, creator: staff_profile)
        put :deny, params: { id: travel_request.to_param, travel_request: invalid_attributes }, session: valid_session
        expect(response).to be_successful
        expect(assigns(:request_change_set).errors.messages).to eq(participation: ["is not included in the list"])
      end
    end
  end

  describe "Put #change_request" do
    it "returns a success response" do
      staff_profile = FactoryBot.create :staff_profile, supervisor: creator
      travel_request = FactoryBot.create(:travel_request, creator: staff_profile)
      notes = { notes: [{ content: "Important message" }] }
      put :change_request, params: { id: travel_request.to_param, travel_request: notes }, session: valid_session
      travel_request.reload
      expect(travel_request.notes.count).to eq 1
      expect(travel_request).to be_changes_requested
    end

    it "does not allow the creator to change_request" do
      travel_request = FactoryBot.create(:travel_request, creator: creator)
      notes = { notes: [{ content: "Important message" }] }
      put :change_request, params: { id: travel_request.to_param, travel_request: notes }, session: valid_session
      expect(response).to redirect_to(travel_request)
      expect(assigns(:request)).to eq(travel_request)
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'review' template)" do
        staff_profile = FactoryBot.create :staff_profile, supervisor: creator
        travel_request = FactoryBot.create(:travel_request, creator: staff_profile)
        put :change_request, params: { id: travel_request.to_param, travel_request: invalid_attributes }, session: valid_session
        expect(response).to be_successful
        expect(assigns(:request_change_set).errors.messages).to eq(participation: ["is not included in the list"])
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested travel_request" do
      travel_request = FactoryBot.create(:travel_request)
      expect do
        delete :destroy, params: { id: travel_request.to_param }, session: valid_session
      end.to change(TravelRequest, :count).by(-1)
    end

    it "redirects to the travel_requests list" do
      travel_request = FactoryBot.create(:travel_request)
      delete :destroy, params: { id: travel_request.to_param }, session: valid_session
      expect(response).to redirect_to(travel_requests_url)
    end
  end
end
