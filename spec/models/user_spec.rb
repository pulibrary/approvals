# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  let(:access_token) { OmniAuth::AuthHash.new(provider: "cas", uid: "who") }

  before do
    FactoryBot.create(:user, uid: "who", provider: "cas")
  end

  describe "relationships" do
    subject(:user) { described_class.from_cas(access_token) }

    it { is_expected.to respond_to :requests }
    it { is_expected.to respond_to :staff_profile }
  end

  describe "#from_cas" do
    it "returns a user object" do
      expect(described_class.from_cas(access_token)).to be_a described_class
    end

    describe "when CAS returns the uid in all caps" do
      let(:access_token) { OmniAuth::AuthHash.new(provider: "cas", uid: "WHO") }

      it "returns a user object" do
        expect(described_class.from_cas(access_token)).to be_a described_class
      end
    end
  end
end
