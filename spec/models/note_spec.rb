# frozen_string_literal: true

require "rails_helper"

RSpec.describe Note, type: :model do
  describe "attributes" do
    subject(:note) { described_class.new }

    it { is_expected.to respond_to :creator }
    it { is_expected.to respond_to :content }
    it { is_expected.to respond_to :request }
  end

  describe "#all" do
    it "is ordered by created_by" do
      absence_request = create(:absence_request)
      note1 = create(:note, request: absence_request)
      travel_request = create(:travel_request)
      note2 = create(:note, request: travel_request)
      note3 = create(:note, request: travel_request)
      note4 = create(:note, request: absence_request)
      expect(described_class.all).to eq([note1, note2, note3, note4])
      expect(absence_request.notes).to eq([note1, note4])
      expect(travel_request.notes).to eq([note2, note3])
    end
  end
end
