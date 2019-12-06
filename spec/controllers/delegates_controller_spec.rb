# frozen_string_literal: true
require "rails_helper"

RSpec.describe DelegatesController, type: :controller do
  let(:delegate) { FactoryBot.create :staff_profile }

  let(:valid_attributes) { { delegate_id: delegate.id } }

  let(:invalid_attributes) { { delegate_id: "blah" } }

  let(:valid_session) { {} }
  let(:user) { FactoryBot.create :user }
  let(:staff_profile) { FactoryBot.create :staff_profile, user: user }

  before do
    staff_profile
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      delegate = FactoryBot.create :delegate, delegator: staff_profile
      FactoryBot.create :delegate
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
      expect(assigns[:delegates]).to eq [delegate]
    end
  end

  describe "GET #index" do
    it "returns delegates the current profile can assume" do
      delegate = FactoryBot.create :delegate, delegate: staff_profile
      FactoryBot.create :delegate
      get :to_assume, params: {}, session: valid_session
      expect(response).to be_successful
      expect(assigns[:delegates]).to eq [delegate]
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      delegate = FactoryBot.create :delegate, delegator: staff_profile
      get :show, params: { id: delegate.to_param }, session: valid_session
      expect(response).to be_successful
    end

    it "returns a redirect to index for bad delegate id" do
      get :show, params: { id: 9999 }, session: valid_session
      expect(response).to redirect_to(delegates_path)
    end

    it "clears invalid delegate" do
      valid_session["approvals_delegate"] = 9999
      delegate = FactoryBot.create :delegate, delegator: staff_profile
      get :show, params: { id: delegate.to_param }, session: valid_session
      expect(session["approvals_delegate"]).to be_blank
      expect(response).to be_successful
    end

    it "clears spoofed delegate" do
      other_delegate = FactoryBot.create :delegate
      valid_session["approvals_delegate"] = other_delegate.id
      delegate = FactoryBot.create :delegate, delegator: staff_profile
      get :show, params: { id: delegate.to_param }, session: valid_session
      expect(session["approvals_delegate"]).to be_blank
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
      delegate = FactoryBot.create :delegate, delegator: staff_profile
      get :edit, params: { id: delegate.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #assume" do
    it "returns a success response" do
      delegate = FactoryBot.create :delegate, delegate: staff_profile
      get :assume, params: { id: delegate.to_param }, session: valid_session
      expect(response).to redirect_to(my_requests_path)
      expect(session["approvals_delegate"]).to eq delegate.id.to_s
      expect(flash[:notice]).to eq "You are now acting on behalf of #{delegate.delegator}"
    end

    context "invalid delegate id" do
      it "returns a redirect response" do
        get :assume, params: { id: 1234 }, session: valid_session
        expect(response).to redirect_to(my_requests_path)
        expect(session["approvals_delegate"]).to be_blank
        expect(flash[:notice]).to eq "Invalid delegation attempt!"
      end
    end

    context "assume another's delegate " do
      it "returns a redirect response" do
        delegate = FactoryBot.create :delegate
        get :assume, params: { id: delegate.to_param }, session: valid_session
        expect(response).to redirect_to(my_requests_path)
        expect(response.headers["APPROVALS-DELEGATE"]).not_to eq delegate.to_s
        expect(flash[:notice]).to eq "Invalid delegation attempt!"
      end
    end
  end

  describe "GET #cancel_delegation" do
    it "returns a success response" do
      delegate = FactoryBot.create :delegate, delegate: staff_profile
      valid_session["approvals_delegate"] = delegate.id.to_s
      get :cancel, session: valid_session
      expect(response).to redirect_to(my_requests_path)
      expect(session["approvals_delegate"]).to be_blank
      expect(flash[:notice]).to eq "You are now acting on your own behalf"
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Delegate" do
        expect do
          post :create, params: { delegate: valid_attributes }, session: valid_session
        end.to change(Delegate, :count).by(1)
      end

      it "redirects to the created delegate" do
        post :create, params: { delegate: valid_attributes }, session: valid_session
        expect(response).to redirect_to(Delegate.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { delegate: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        skip("Add a hash of attributes valid for your model")
      end

      it "updates the requested delegate" do
        delegate = FactoryBot.create :delegate, delegator: staff_profile
        put :update, params: { id: delegate.to_param, delegate: new_attributes }, session: valid_session
        delegate.reload
        skip("Add assertions for updated state")
      end

      it "redirects to the delegate" do
        delegate = FactoryBot.create :delegate, delegator: staff_profile
        put :update, params: { id: delegate.to_param, delegate: valid_attributes }, session: valid_session
        expect(response).to redirect_to(delegate)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        delegate = FactoryBot.create :delegate, delegator: staff_profile
        put :update, params: { id: delegate.to_param, delegate: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested delegate" do
      delegate = FactoryBot.create :delegate, delegator: staff_profile
      expect do
        delete :destroy, params: { id: delegate.to_param }, session: valid_session
      end.to change(Delegate, :count).by(-1)
    end

    it "redirects to the delegates list" do
      delegate = FactoryBot.create :delegate, delegator: staff_profile
      delete :destroy, params: { id: delegate.to_param }, session: valid_session
      expect(response).to redirect_to(delegates_url)
    end
  end
end
