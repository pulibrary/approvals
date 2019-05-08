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
  let(:creator) { FactoryBot.create(:staff_profile) }

  # This should return the minimal set of attributes required to create a valid
  # AbsenceRequest. As you add validations to AbsenceRequest, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      creator_id: creator.id,
      start_date: Time.zone.today,
      end_date: Time.zone.tomorrow,
      request_type: "AbsenceRequest",
      absence_type: "vacation_monthly"
    }
  end

  let(:invalid_attributes) do
    skip("Add a hash of attributes invalid for your model")
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AbsenceRequestsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:user) { FactoryBot.create :user }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      FactoryBot.create(:absence_request)
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      absence_request = FactoryBot.create(:absence_request)
      get :show, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      absence_request = FactoryBot.create(:absence_request)
      get :edit, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new AbsenceRequest" do
        expect do
          post :create, params: { absence_request: valid_attributes }, session: valid_session
        end.to change(AbsenceRequest, :count).by(1)
      end

      it "redirects to the created absence_request" do
        post :create, params: { absence_request: valid_attributes }, session: valid_session
        expect(response).to redirect_to(AbsenceRequest.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { absence_request: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    context "with valid nested attributes" do
      let(:nested_attributes) do
        {
          notes_attributes: [{ creator_id: creator.id, content: "Important message" }]
        }
      end

      it "updates the requested absence_request" do
        absence_request = FactoryBot.create(:absence_request)
        put :update, params: { id: absence_request.to_param, absence_request: nested_attributes }, session: valid_session
        absence_request.reload
        expect(absence_request.notes.count).to eq 1
        expect(absence_request.notes.last.content).to eq "Important message"
      end

      it "redirects to the absence_request" do
        absence_request = FactoryBot.create(:absence_request)
        put :update, params: { id: absence_request.to_param, absence_request: nested_attributes }, session: valid_session
        expect(response).to redirect_to(absence_request)
      end
    end

    context "with invalid params" do
      let(:invalid_nested_attributes) do
        {
          notes_attributes: [{ creator_id: user.id, content: "Important message" }]
        }
      end

      it "returns a success response (i.e. to display the 'edit' template)" do
        absence_request = FactoryBot.create(:absence_request)
        put :update, params: { id: absence_request.to_param, absence_request: invalid_nested_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested absence_request" do
      absence_request = FactoryBot.create(:absence_request)
      expect do
        delete :destroy, params: { id: absence_request.to_param }, session: valid_session
      end.to change(AbsenceRequest, :count).by(-1)
    end

    it "redirects to the absence_requests list" do
      absence_request = FactoryBot.create(:absence_request)
      delete :destroy, params: { id: absence_request.to_param }, session: valid_session
      expect(response).to redirect_to(absence_requests_url)
    end
  end
end
