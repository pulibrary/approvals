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

RSpec.describe ApprovalsController, type: :controller do
  let(:event_request) { FactoryBot.create(:event_request) }
  let(:approver) { FactoryBot.create(:staff_profile) }
  let(:travel_request) { FactoryBot.create(:travel_request) }

  # This should return the minimal set of attributes required to create a valid
  # Approval. As you add validations to Approval, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      approver_id: approver.id,
      request_id: travel_request.id,
      approved: true
    }
  end

  let(:invalid_attributes) do
    {
      approver_id: nil,
      request_id: nil,
      approved: true
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ApprovalsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:user) { FactoryBot.create :user }
  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      FactoryBot.create(:approval)
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
      assert_equal Approval.all, assigns(:approvals)
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      approval = FactoryBot.create(:approval)
      get :show, params: { id: approval.to_param }, session: valid_session
      expect(response).to be_successful
      assert_equal approval, assigns(:approval)
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
      expect(assigns(:approval)).to be_an(Approval)
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      approval = FactoryBot.create(:approval)
      get :edit, params: { id: approval.to_param }, session: valid_session
      expect(response).to be_successful
      assert_equal approval, assigns(:approval)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Approval" do
        expect do
          post :create, params: { approval: valid_attributes }, session: valid_session
        end.to change(Approval, :count).by(1)
      end

      it "redirects to the created approval" do
        post :create, params: { approval: valid_attributes }, session: valid_session
        expect(response).to redirect_to(Approval.last)
        expect(assigns(:approval)).to eq(Approval.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { approval: invalid_attributes }, session: valid_session
        expect(response).to be_successful
        expect(assigns(:approval)).to be_an(Approval)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        {
          approved: true
        }
      end

      it "updates the requested approval" do
        approval = FactoryBot.create(:approval)
        put :update, params: { id: approval.to_param, approval: new_attributes }, session: valid_session
        approval.reload
        expect(approval.approved).to be_truthy
      end

      it "redirects to the approval" do
        approval = FactoryBot.create(:approval)
        put :update, params: { id: approval.to_param, approval: valid_attributes }, session: valid_session
        expect(response).to redirect_to(approval)
        expect(assigns(:approval)).to be_an(Approval)
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

      it "updates the requested approval" do
        approval = FactoryBot.create(:approval, valid_attributes)
        put :update, params: { id: approval.to_param, approval: nested_attributes }, session: valid_session
        approval.reload
        expect(approval.request.travel_category).to eq "business"
        expect(approval.request.notes.last.content).to eq "Approver message"
        expect(approval.request.event_requests.first.recurring_event_id).to eq new_recurring_event.id
      end

      it "redirects to the approval" do
        approval = FactoryBot.create(:approval, valid_attributes)
        put :update, params: { id: approval.to_param, approval: nested_attributes }, session: valid_session
        expect(response).to redirect_to(approval)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        approval = FactoryBot.create(:approval)
        put :update, params: { id: approval.to_param, approval: invalid_attributes }, session: valid_session
        expect(response).to be_successful
        expect(assigns(:approval).attributes.with_indifferent_access).to include(invalid_attributes)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested approval" do
      approval = FactoryBot.create(:approval)
      expect do
        delete :destroy, params: { id: approval.to_param }, session: valid_session
      end.to change(Approval, :count).by(-1)
    end

    it "redirects to the approvals list" do
      approval = FactoryBot.create(:approval)
      delete :destroy, params: { id: approval.to_param }, session: valid_session
      expect(response).to redirect_to(approvals_url)
    end
  end
end
