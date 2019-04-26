require "rails_helper"

RSpec.describe User, type: :model do
  let(:access_token) { OmniAuth::AuthHash.new(provider: "cas", uid: "who") }

  before do
    FactoryBot.create(:user, uid: "who", provider: "cas")
  end

  describe "#from_cas" do
    it "returns a user object" do
      expect(User.from_cas(access_token)).to be_a User
    end
  end
end
