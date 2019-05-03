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

RSpec.describe StaffProfilesController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # StaffProfile. As you add validations to StaffProfile, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    { department_id: FactoryBot.create(:department).id,
      user_id: FactoryBot.create(:user).id,
      supervisor_id: FactoryBot.create(:staff_profile).id,
      biweekly: false }
  end

  let(:invalid_attributes) do
    { user_id: 100 }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # StaffProfilesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:user) { FactoryBot.create :user }
  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      StaffProfile.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      staff_profile = StaffProfile.create! valid_attributes
      get :show, params: { id: staff_profile.to_param }, session: valid_session
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
      staff_profile = StaffProfile.create! valid_attributes
      get :edit, params: { id: staff_profile.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new StaffProfile" do
        valid_attributes # do this here so the supervisor gets created before we post the data
        expect do
          post :create, params: { staff_profile: valid_attributes }, session: valid_session
        end.to change(StaffProfile, :count).by(1)
      end

      it "redirects to the created staff_profile" do
        post :create, params: { staff_profile: valid_attributes }, session: valid_session
        expect(response).to redirect_to(StaffProfile.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { staff_profile: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        { biweekly: true }
      end

      it "updates the requested staff_profile" do
        staff_profile = StaffProfile.create! valid_attributes
        put :update, params: { id: staff_profile.to_param, staff_profile: new_attributes }, session: valid_session
        staff_profile.reload
        expect(staff_profile.biweekly).to be_truthy
      end

      it "redirects to the staff_profile" do
        staff_profile = StaffProfile.create! valid_attributes
        put :update, params: { id: staff_profile.to_param, staff_profile: valid_attributes }, session: valid_session
        expect(response).to redirect_to(staff_profile)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        staff_profile = StaffProfile.create! valid_attributes
        put :update, params: { id: staff_profile.to_param, staff_profile: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested staff_profile" do
      staff_profile = StaffProfile.create! valid_attributes
      expect do
        delete :destroy, params: { id: staff_profile.to_param }, session: valid_session
      end.to change(StaffProfile, :count).by(-1)
    end

    it "redirects to the staff_profiles list" do
      staff_profile = StaffProfile.create! valid_attributes
      delete :destroy, params: { id: staff_profile.to_param }, session: valid_session
      expect(response).to redirect_to(staff_profiles_url)
    end
  end
end