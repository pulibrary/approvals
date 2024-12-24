# frozen_string_literal: true

require "rails_helper"

RSpec.describe DelegatesController, type: :controller do
  let(:delegate) { FactoryBot.create :staff_profile }

  let(:valid_attributes) { { delegate_id: delegate.id } }

  let(:invalid_attributes) { { delegate_id: "blah" } }

  let(:valid_session) { {} }
  let(:user) { FactoryBot.create :user }
  let(:staff_profile) { FactoryBot.create :staff_profile, user: }

  before do
    staff_profile
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      sally_smith = FactoryBot.create :staff_profile, given_name: "Sally", surname: "Smith"
      jane_doe = FactoryBot.create :staff_profile, given_name: "Jane", surname: "Doe"
      delegate = FactoryBot.create :delegate, delegator: staff_profile, delegate: sally_smith
      delegate2 = FactoryBot.create :delegate, delegator: staff_profile, delegate: jane_doe
      FactoryBot.create :delegate
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
      expect(assigns[:delegates]).to eq [delegate2, delegate]
    end
  end

  describe "GET #assume" do
    it "returns a success response" do
      delegate = FactoryBot.create :delegate, delegate: staff_profile
      get :assume, params: { id: delegate.to_param }, session: valid_session
      expect(response).to redirect_to(my_requests_path)
      expect(session["approvals_delegate"]).to eq delegate.id.to_s
      expect(flash[:success]).to eq "You are now acting on behalf of #{delegate.delegator}"
    end

    context "invalid delegate id" do
      it "returns a redirect response" do
        get :assume, params: { id: 1234 }, session: valid_session
        expect(response).to redirect_to(my_requests_path)
        expect(session["approvals_delegate"]).to be_blank
        expect(flash[:error]).to eq "Invalid delegation attempt!"
      end
    end

    context "assume another's delegate" do
      it "returns a redirect response" do
        delegate = FactoryBot.create :delegate
        get :assume, params: { id: delegate.to_param }, session: valid_session
        expect(response).to redirect_to(my_requests_path)
        expect(response.headers["APPROVALS-DELEGATE"]).not_to eq delegate.to_s
        expect(flash[:error]).to eq "Invalid delegation attempt!"
      end
    end

    context "when you are being delegate" do
      it "does not allow you to assume a delegation" do
        delegate = FactoryBot.create :delegate, delegate: staff_profile
        delegate2 = FactoryBot.create :delegate, delegate: delegate.delegator
        valid_session["approvals_delegate"] = delegate.id.to_s
        get :assume, params: { id: delegate2.to_param }, session: valid_session
        expect(response).to redirect_to(my_requests_path)
        expect(response.headers["APPROVALS-DELEGATE"]).not_to eq delegate.to_s
        expect(flash[:error]).to eq "You can not modify delegations as a delegate"
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
      expect(flash[:success]).to eq "You are now acting on your own behalf"
    end
  end

  describe "GET #to_assume" do
    it "returns a success response" do
      sally_smith = FactoryBot.create :staff_profile, given_name: "Sally", surname: "Smith"
      jane_doe = FactoryBot.create :staff_profile, given_name: "Jane", surname: "Doe"
      delegate = FactoryBot.create :delegate, delegate: staff_profile, delegator: sally_smith
      delegate2 = FactoryBot.create :delegate, delegate: staff_profile, delegator: jane_doe
      FactoryBot.create :delegate
      get :to_assume, params: {}, session: valid_session
      expect(response).to be_successful
      expect(assigns[:delegators]).to eq [delegate2, delegate]
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Delegate" do
        expect do
          post :create, params: { delegate: valid_attributes }, session: valid_session
        end.to change(Delegate, :count).by(1)
      end

      it "redirects to the delegates list" do
        post :create, params: { delegate: valid_attributes }, session: valid_session
        expect(response).to redirect_to(delegates_url)
      end
    end

    context "with invalid params" do
      it "renders the new form" do
        post :create, params: { delegate: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end

    context "when you are being delegate" do
      it "does not allow you to create a delegation" do
        delegate = FactoryBot.create :delegate, delegate: staff_profile
        valid_session["approvals_delegate"] = delegate.id.to_s
        post :create, params: { delegate: valid_attributes }, session: valid_session
        expect(response).to redirect_to(my_requests_path)
        expect(response.headers["APPROVALS-DELEGATE"]).not_to eq delegate.to_s
        expect(flash[:error]).to eq "You can not modify delegations as a delegate"
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

    it "errors on bad delegate" do
      delete :destroy, params: { id: 123 }, session: valid_session
      expect(response).to redirect_to(delegates_url)
    end

    it "does not allow you to assume a delegation" do
      delegate = FactoryBot.create :delegate, delegate: staff_profile
      delegate2 = FactoryBot.create :delegate, delegate: delegate.delegator
      valid_session["approvals_delegate"] = delegate.id.to_s
      expect do
        delete :destroy, params: { id: delegate2.to_param }, session: valid_session
      end.not_to change(Delegate, :count)
      expect(response).to redirect_to(my_requests_path)
      expect(response.headers["APPROVALS-DELEGATE"]).not_to eq delegate.to_s
      expect(flash[:error]).to eq "You can not modify delegations as a delegate"
    end
  end
end
