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

RSpec.describe AbsenceRequestsController, type: :controller do
  let(:creator) { FactoryBot.create(:staff_profile, :with_supervisor, user: user) }

  # This should return the minimal set of attributes required to create a valid
  # AbsenceRequest. As you add validations to AbsenceRequest, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      start_date: Time.zone.today,
      end_date: Time.zone.tomorrow,
      request_type: "AbsenceRequest",
      absence_type: "vacation",
      hours_requested: 16
    }
  end

  let(:invalid_attributes) do
    { absence_type: "bad_one" }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AbsenceRequestsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:user) { FactoryBot.create :user }

  before do
    sign_in creator.user
  end

  describe "GET #show" do
    it "returns a success response for the creator" do
      absence_request = FactoryBot.create(:absence_request, creator: creator)
      get :show, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to be_successful
      assert_equal absence_request, assigns(:request).request
    end

    it "returns a success response for the creator's supervisor" do
      staff_profile = FactoryBot.create(:staff_profile, supervisor: creator)
      absence_request = FactoryBot.create(:absence_request, creator: staff_profile)
      get :show, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to be_successful
      assert_equal absence_request, assigns(:request).request
    end

    it "returns a success response for the creator's supervisor's supervisor" do
      staff_supervisor = FactoryBot.create(:staff_profile, supervisor: creator)
      staff_profile = FactoryBot.create(:staff_profile, supervisor: staff_supervisor)
      absence_request = FactoryBot.create(:absence_request, creator: staff_profile)
      get :show, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to be_successful
      assert_equal absence_request, assigns(:request).request
    end

    it "can not show a request created by another user" do
      absence_request = FactoryBot.create(:absence_request)
      get :show, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to redirect_to(my_requests_path)
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
      expect(assigns(:request_change_set)).to be_a AbsenceRequestChangeSet
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      absence_request = FactoryBot.create(:absence_request, creator: creator)
      get :edit, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to be_successful
      expect(assigns(:request_change_set)).to be_a AbsenceRequestChangeSet
    end

    it "can not edit an approved request" do
      absence_request = FactoryBot.create(:absence_request, creator: creator, action: "approve")
      get :edit, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to redirect_to(absence_request)
      expect(assigns(:request)).to eq(absence_request)
    end

    it "can not edit a denied request" do
      absence_request = FactoryBot.create(:absence_request, creator: creator, action: "deny")
      get :edit, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to redirect_to(absence_request)
      expect(assigns(:request)).to eq(absence_request)
    end

    it "can not edit a recorded request" do
      absence_request = FactoryBot.create(:absence_request, creator: creator, action: "record")
      get :edit, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to redirect_to(absence_request)
      expect(assigns(:request)).to eq(absence_request)
    end

    it "can not edit a canceled request" do
      absence_request = FactoryBot.create(:absence_request, creator: creator, action: "cancel")
      get :edit, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to redirect_to(absence_request)
      expect(assigns(:request)).to eq(absence_request)
    end

    it "can not edit a request created by another user" do
      absence_request = FactoryBot.create(:absence_request)
      get :edit, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to redirect_to(absence_request)
      expect(assigns(:request)).to eq(absence_request)
    end
  end

  describe "GET #review" do
    it "returns a success response" do
      staff_profile = FactoryBot.create :staff_profile, supervisor: creator
      absence_request = FactoryBot.create(:absence_request, creator: staff_profile)
      get :review, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to be_successful
      expect(assigns(:request_change_set)).to be_a AbsenceRequestChangeSet
    end

    it "Does not allow review after approved" do
      staff_profile = FactoryBot.create :staff_profile, supervisor: creator
      absence_request = FactoryBot.create(:absence_request, creator: staff_profile)
      absence_request.approve!(agent: creator)
      get :review, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to redirect_to(absence_request)
      expect(assigns(:request)).to eq(absence_request)
      expect(flash[:error]).to eq "Absence request can not be reviewed after it has been approved."
    end

    it "does not allow the creator to review" do
      absence_request = FactoryBot.create(:absence_request, creator: creator)
      get :review, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to redirect_to(absence_request)
      expect(assigns(:request)).to eq(absence_request)
    end

    it "Does not allow review after denied" do
      staff_profile = FactoryBot.create :staff_profile, supervisor: creator
      absence_request = FactoryBot.create(:absence_request, creator: staff_profile, action: "deny")
      get :review, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to redirect_to(absence_request)
      expect(assigns(:request)).to eq(absence_request)
    end
  end

  describe "Put #decide" do
    it "approves and does not add a note if none is submitted" do
      staff_profile = FactoryBot.create :staff_profile, :with_department, supervisor: creator
      absence_request = FactoryBot.create(:absence_request, creator: staff_profile)
      notes = { notes: [{ content: "Important message" }] }
      put :decide, params: { id: absence_request.to_param, absence_request: notes, approve: "" }, session: valid_session
      absence_request.reload
      expect(absence_request.notes.count).to eq 1
      expect(absence_request).to be_approved
      expect(absence_request.creator).to eq(staff_profile)
    end

    it "does not allow the creator to approve" do
      absence_request = FactoryBot.create(:absence_request, creator: creator)
      notes = { notes: [{ content: "Important message" }] }
      put :decide, params: { id: absence_request.to_param, absence_request: notes, approve: "" }, session: valid_session
      expect(response).to redirect_to(absence_request)
      expect(assigns(:request)).to eq(absence_request)
    end

    context "approve with invalid params" do
      it "returns a success response (i.e. to display the 'review' template)" do
        staff_profile = FactoryBot.create :staff_profile, supervisor: creator
        absence_request = FactoryBot.create(:absence_request, creator: staff_profile)
        put :decide, params: { id: absence_request.to_param, absence_request: invalid_attributes, approve: "" }, session: valid_session
        expect(response).to be_successful
        expect(assigns(:request_change_set).errors.messages).to eq(absence_type: ["is not included in the list"])
      end
    end

    it "returns a success response" do
      staff_profile = FactoryBot.create :staff_profile, supervisor: creator
      absence_request = FactoryBot.create(:absence_request, creator: staff_profile)
      notes = { notes: [{ content: "Important message" }] }
      put :decide, params: { id: absence_request.to_param, absence_request: notes, deny: "" }, session: valid_session
      absence_request.reload
      expect(absence_request.notes.count).to eq 1
      expect(absence_request).to be_denied
    end

    it "does not allow the creator to deny" do
      absence_request = FactoryBot.create(:absence_request, creator: creator)
      notes = { notes: [{ content: "Important message" }] }
      put :decide, params: { id: absence_request.to_param, absence_request: notes, deny: "" }, session: valid_session
      expect(response).to redirect_to(absence_request)
      expect(assigns(:request)).to eq(absence_request)
    end

    context "deny with invalid params" do
      it "returns a success response (i.e. to display the 'review' template)" do
        staff_profile = FactoryBot.create :staff_profile, supervisor: creator
        absence_request = FactoryBot.create(:absence_request, creator: staff_profile)
        put :decide, params: { id: absence_request.to_param, absence_request: invalid_attributes, deny: "" }, session: valid_session
        expect(response).to be_successful
        expect(assigns(:request_change_set).errors.messages).to eq(absence_type: ["is not included in the list"], notes: ["are required to deny a request"])
      end
    end

    it "cancel by the creator with notes returns a success response" do
      absence_request = FactoryBot.create(:absence_request, creator: creator)
      notes = { notes: [{ content: "Important message" }] }
      put :decide, params: { id: absence_request.to_param, absence_request: notes, cancel: "" }, session: valid_session
      absence_request.reload
      expect(absence_request.notes.count).to eq 1
      expect(absence_request).to be_canceled
    end

    it "cancel and approved request by the creator returns a success response" do
      absence_request = FactoryBot.create(:absence_request, creator: creator, action: :approve)
      put :decide, params: { id: absence_request.to_param, cancel: "" }, session: valid_session
      absence_request.reload
      expect(absence_request.notes.count).to eq 0
      expect(absence_request).to be_canceled
    end

    it "cancel by the creator returns a success response" do
      absence_request = FactoryBot.create(:absence_request, creator: creator)
      put :decide, params: { id: absence_request.to_param, cancel: "" }, session: valid_session
      absence_request.reload
      expect(absence_request.notes.count).to eq 0
      expect(absence_request).to be_canceled
    end

    it "does not allow the supervisor to cancel" do
      staff_profile = FactoryBot.create :staff_profile, supervisor: creator
      absence_request = FactoryBot.create(:absence_request, creator: staff_profile)
      notes = { notes: [{ content: "Important message" }] }
      put :decide, params: { id: absence_request.to_param, absence_request: notes, cancel: "" }, session: valid_session
      expect(response).to redirect_to(absence_request)
      expect(assigns(:request)).to eq(absence_request)
    end

    context "cancel with invalid params" do
      it "returns a success response (i.e. to display the 'review' template)" do
        absence_request = FactoryBot.create(:absence_request, creator: creator)
        put :decide, params: { id: absence_request.to_param, absence_request: invalid_attributes, cancel: "" }, session: valid_session
        expect(response).to be_successful
        expect(assigns(:request_change_set).errors.messages).to eq(absence_type: ["is not included in the list"])
      end
    end

    it "allows the creator to record an approved request" do
      absence_request = FactoryBot.create(:absence_request, creator: creator, action: :approve)
      put :decide, params: { id: absence_request.to_param, record: "" }, session: valid_session
      absence_request.reload
      expect(absence_request).to be_recorded
    end

    it "allows the supervisor to record an approved request" do
      employee = FactoryBot.create(:staff_profile, supervisor: creator)
      absence_request = FactoryBot.create(:absence_request, creator: employee, action: :approve)
      put :decide, params: { id: absence_request.to_param, record: "" }, session: valid_session
      absence_request.reload
      expect(absence_request).to be_recorded
    end

    it "does not allow the creator to record an pending request" do
      absence_request = FactoryBot.create(:absence_request, creator: creator)
      put :decide, params: { id: absence_request.to_param, record: "" }, session: valid_session
      absence_request.reload
      expect(absence_request).to be_pending
    end

    it "does not allow the creator to record an canceled request" do
      absence_request = FactoryBot.create(:absence_request, creator: creator, action: :cancel)
      put :decide, params: { id: absence_request.to_param, record: "" }, session: valid_session
      absence_request.reload
      expect(absence_request).to be_canceled
    end

    it "does not allow a random person to record an approved request" do
      absence_request = FactoryBot.create(:absence_request, action: :approve)
      put :decide, params: { id: absence_request.to_param, record: "" }, session: valid_session
      absence_request.reload
      expect(absence_request).to be_approved
    end

    it "comments and returns a success with notes response" do
      absence_request = FactoryBot.create(:absence_request, creator: creator)
      notes = { notes: [{ content: "Important message" }] }
      put :decide, params: { id: absence_request.to_param, absence_request: notes, comment: "" }, session: valid_session
      absence_request.reload
      expect(response).to redirect_to(absence_request)
      expect(assigns(:request)).to eq(absence_request)
      expect(absence_request.notes.count).to eq 1
    end

    it "comments require notes" do
      absence_request = FactoryBot.create(:absence_request, creator: creator)
      put :decide, params: { id: absence_request.to_param, absence_request: { abc: "123" }, comment: "" }, session: valid_session
      expect(assigns(:request_change_set).errors.messages).to eq(notes: ["are required to comment on a request"])
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new AbsenceRequest" do
        expect do
          post :create, params: { absence_request: valid_attributes }, session: valid_session
        end.to change(AbsenceRequest, :count).by(1).and change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it "redirects to the created absence_request" do
        post :create, params: { absence_request: valid_attributes }, session: valid_session
        absence_request = AbsenceRequest.last
        expect(response).to redirect_to(absence_request)
        expect(assigns(:request)).to eq(absence_request)
        expect(absence_request.creator_id).to eq creator.id
      end

      it "returns json when requested" do
        post :create, params: { absence_request: valid_attributes, format: :json }, session: valid_session
        absence_request = AbsenceRequest.last
        expect(response.media_type).to eq("application/json")
        expect(assigns(:request)).to eq(absence_request)
        expect(absence_request.creator_id).to eq creator.id
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { absence_request: invalid_attributes }, session: valid_session
        expect(response).to be_successful
        expect(assigns(:request_change_set).errors.messages).to eq(absence_type: ["is not included in the list"],
                                                                   end_date: ["can't be blank"],
                                                                   hours_requested: ["can't be blank"],
                                                                   start_date: ["can't be blank"])
      end

      it "returns json with errors" do
        post :create, params: { absence_request: invalid_attributes, format: :json }, session: valid_session
        expect(response).not_to be_successful
        expect(response.media_type).to eq("application/json")
        expect(response.body).to eq('{"absence_type":["is not included in the list"],"end_date":["can\'t be blank"],"hours_requested":["can\'t be blank"],"start_date":["can\'t be blank"]}')
      end
    end

    # rubocop:disable RSpec/AnyInstance
    context "invalid save to database" do
      before do
        allow_any_instance_of(AbsenceRequest).to receive(:save).and_return(false)
        bad_note = Note.new(creator_id: 123)
        bad_note.save
        allow_any_instance_of(AbsenceRequest).to receive(:errors).and_return(bad_note.errors)
      end

      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { absence_request: valid_attributes }, session: valid_session
        expect(response).to be_successful
        expect(assigns(:request_change_set).errors.messages).to eq(request: ["must exist"], creator: ["must exist"])
      end

      it "returns json with errors" do
        post :create, params: { absence_request: valid_attributes, format: :json }, session: valid_session
        expect(response).not_to be_successful
        expect(response.media_type).to eq("application/json")
        expect(response.body).to eq('{"request":["must exist"],"creator":["must exist"]}')
      end
    end
    # rubocop:enable RSpec/AnyInstance
  end

  describe "PUT #update" do
    let(:valid_attributes) { { absence_type: "sick" } }
    let(:absence_request) { FactoryBot.create(:absence_request, creator: creator) }

    context "with valid nested attributes" do
      let(:nested_attributes) do
        {
          notes: [{ content: "Important message" }]
        }
      end

      it "does not add a note if none is submitted" do
        put :update, params: { id: absence_request.to_param, absence_request: valid_attributes }, session: valid_session
        absence_request.reload
        expect(absence_request.notes.count).to eq 0
      end

      it "adds a nested note" do
        put :update, params: { id: absence_request.to_param, absence_request: nested_attributes }, session: valid_session
        absence_request.reload
        expect(absence_request.notes.count).to eq 1
        expect(absence_request.notes.last.content).to eq "Important message"
      end

      it "adds a nested note to note array which already had a note" do
        absence_request = FactoryBot.create(:absence_request, :with_note)
        put :update, params: { id: absence_request.to_param, absence_request: nested_attributes }, session: valid_session
        absence_request.reload
        expect(absence_request.notes.count).to eq 2
        expect(absence_request.notes.last.content).to eq "Important message"
      end

      it "redirects to the absence_request" do
        put :update, params: { id: absence_request.to_param, absence_request: nested_attributes }, session: valid_session
        expect(response).to redirect_to(absence_request)
        expect(assigns(:request).notes.first.attributes.with_indifferent_access).to include(nested_attributes[:notes].first)
      end
    end

    # rubocop:disable RSpec/AnyInstance
    context "invalid save to database" do
      before do
        absence_request # make sure our item is created before we stub
        allow_any_instance_of(AbsenceRequest).to receive(:save).and_return(false)
        bad_note = Note.new(creator_id: 123)
        bad_note.save
        allow_any_instance_of(AbsenceRequest).to receive(:errors).and_return(bad_note.errors)
      end

      it "returns a success response (i.e. to display the 'new' template)" do
        put :update, params: { id: absence_request.to_param, absence_request: valid_attributes }, session: valid_session
        expect(response).to be_successful
        expect(assigns(:request_change_set).errors.messages).to eq(request: ["must exist"], creator: ["must exist"])
      end

      it "returns json with errors" do
        put :update, params: { id: absence_request.to_param, absence_request: valid_attributes, format: :json }, session: valid_session
        expect(response).not_to be_successful
        expect(response.media_type).to eq("application/json")
        expect(response.body).to eq('{"request":["must exist"],"creator":["must exist"]}')
      end
    end
    # rubocop:enable RSpec/AnyInstance

    context "with empty note content" do
      let(:empty_note_attribute) do
        {
          notes: [{ content: nil }]
        }
      end

      it "redirects to the absence request" do
        absence_request = FactoryBot.create(:absence_request, creator: creator)
        expect do
          put :update, params: { id: absence_request.to_param, absence_request: empty_note_attribute }, session: valid_session
          expect(response).to redirect_to(absence_request)
        end.to change(Note, :count).by(0)
      end
    end

    context "Already in the approval process" do
      it "does not allow updates to the attributes" do
        absence_request.approve(agent: absence_request.creator.supervisor)
        absence_request.save
        put :update, params: { id: absence_request.to_param, absence_request: valid_attributes }, session: valid_session
        expect(response).to redirect_to(absence_request)
        expect(absence_request.reload.absence_type).not_to eq("sick")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested absence_request" do
      absence_request = FactoryBot.create(:absence_request, creator: creator)
      expect do
        delete :destroy, params: { id: absence_request.to_param }, session: valid_session
      end.to change(AbsenceRequest, :count).by(-1)
    end

    it "redirects to the absence_requests list" do
      absence_request = FactoryBot.create(:absence_request, creator: creator)
      delete :destroy, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to redirect_to(absence_requests_url)
    end
  end
end
