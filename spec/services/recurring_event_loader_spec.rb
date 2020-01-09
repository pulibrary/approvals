# frozen_string_literal: true
require "rails_helper"

RSpec.describe RecurringEventLoader, type: :model do
  let(:staff_profile) { FactoryBot.create :staff_profile }
  let(:user) { staff_profile.user }
  describe "#list" do
    it "parses the config and creates the RecurringEvents" do
      file = Tempfile.new("RecurringEvents.yml")
      file.write("- Access Conference\n")
      file.write("- American Institute for Conservation (AIC)\n")
      file.rewind
      file.close
      RecurringEventLoader.load(config_file: file.path)
      expect(RecurringEvent.all.map(&:name)).to eq(["Access Conference", "American Institute for Conservation (AIC)"])
      file.unlink
    end
  end
end
