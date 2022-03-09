# frozen_string_literal: true
require "rails_helper"

RSpec.describe HomeURL, type: :model do
  let(:jack) { FactoryBot.create :user }

  describe "#for" do
    it "returns root path for empty current_user" do
      expect(described_class.for(current_user: nil)).to eq("/")
    end
    it "returns my requests path for filled in current_user" do
      expect(described_class.for(current_user: jack)).to eq("/my_requests")
    end
  end
end
