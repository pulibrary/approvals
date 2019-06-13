# frozen_string_literal: true
require "rails_helper"

RSpec.describe StateChangesController, type: :controller do
  let(:event_request) { FactoryBot.create(:event_request) }
  let(:approver) { FactoryBot.create(:staff_profile) }
  let(:travel_request) { FactoryBot.create(:travel_request) }

  # This should return the minimal set of attributes required to create a valid
  # StateChange. As you add validations to StateChange, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      approver_id: approver.id,
      request_id: travel_request.id,
      action: "approved"
    }
  end

  let(:invalid_attributes) do
    {
      approver_id: nil,
      request_id: nil,
      action: "bad"
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # StateChangesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:user) { FactoryBot.create :user }
  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      FactoryBot.create(:state_change)
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
      assert_equal StateChange.all, assigns(:state_changes)
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      state_change = FactoryBot.create(:state_change)
      get :show, params: { id: state_change.to_param }, session: valid_session
      expect(response).to be_successful
      assert_equal state_change, assigns(:state_change)
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
      expect(assigns(:state_change)).to be_an(StateChange)
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      state_change = FactoryBot.create(:state_change)
      get :edit, params: { id: state_change.to_param }, session: valid_session
      expect(response).to be_successful
      assert_equal state_change, assigns(:state_change)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new StateChange" do
        expect do
          post :create, params: { state_change: valid_attributes }, session: valid_session
        end.to change(StateChange, :count).by(1)
      end

      it "redirects to the created state_change" do
        post :create, params: { state_change: valid_attributes }, session: valid_session
        expect(response).to redirect_to(StateChange.last)
        expect(assigns(:state_change)).to eq(StateChange.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { state_change: invalid_attributes }, session: valid_session
        expect(response).to be_successful
        expect(assigns(:state_change)).to be_an(StateChange)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        {
          action: "changes_requested"
        }
      end

      it "updates the requested state_change" do
        state_change = FactoryBot.create(:state_change)
        put :update, params: { id: state_change.to_param, state_change: new_attributes }, session: valid_session
        state_change.reload
        expect(state_change.action).to eq "changes_requested"
      end

      it "redirects to the state_change" do
        state_change = FactoryBot.create(:state_change)
        put :update, params: { id: state_change.to_param, state_change: valid_attributes }, session: valid_session
        expect(response).to redirect_to(state_change)
        expect(assigns(:state_change)).to be_an(StateChange)
      end
    end

    context "with valid nested attributes for notes and the recurring event changing" do
      let(:new_recurring_event) { FactoryBot.create(:recurring_event) }
      let(:nested_attributes) do
        {
          request_attributes: {
            id: travel_request.id,
            travel_category: "business",
            notes_attributes: [{
              creator_id: approver.id,
              content: "Approver message"
            }],
            event_requests_attributes: [{
              id: travel_request.event_requests.last.id,
              recurring_event_id: new_recurring_event.id
            }]
          }
        }
      end

      it "updates the requested state_change" do
        state_change = FactoryBot.create(:state_change, valid_attributes)
        put :update, params: { id: state_change.to_param, state_change: nested_attributes }, session: valid_session
        state_change.reload
        expect(state_change.request.travel_category).to eq "business"
        expect(state_change.request.notes.last.content).to eq "Approver message"
        expect(state_change.request.event_requests.first.recurring_event_id).to eq new_recurring_event.id
      end

      it "redirects to the state_change" do
        state_change = FactoryBot.create(:state_change, valid_attributes)
        put :update, params: { id: state_change.to_param, state_change: nested_attributes }, session: valid_session
        expect(response).to redirect_to(state_change)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        state_change = FactoryBot.create(:state_change)
        put :update, params: { id: state_change.to_param, state_change: invalid_attributes }, session: valid_session
        expect(response).to be_successful
        expect(assigns(:state_change).attributes.with_indifferent_access).to include(invalid_attributes)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested state_change" do
      state_change = FactoryBot.create(:state_change)
      expect do
        delete :destroy, params: { id: state_change.to_param }, session: valid_session
      end.to change(StateChange, :count).by(-1)
    end

    it "redirects to the state_changes list" do
      state_change = FactoryBot.create(:state_change)
      delete :destroy, params: { id: state_change.to_param }, session: valid_session
      expect(response).to redirect_to(state_changes_url)
    end
  end
end
