# frozen_string_literal: true

require "rails_helper"

RSpec.describe LocationLoader, type: :model do
  let(:staff_profile) { create(:staff_profile) }
  let(:user) { staff_profile.user }

  describe "#list" do
    it "parses the config and creates the locations" do
      file = Tempfile.new("locations.yml")
      file.write("- building: Firestone Library\n")
      file.write("- building: Other Library\n")
      file.rewind
      file.close
      described_class.load(config_file: file.path)
      expect(Location.all.map(&:building)).to contain_exactly("Firestone Library", "Other Library")
      file.unlink
    end

    it "parses the config and connects the aa" do
      file = Tempfile.new("locations.yml")
      file.write("- building: Firestone Library\n")
      file.write("  admin_assistant: #{user.uid}\n")
      file.rewind
      file.close
      described_class.load(config_file: file.path)
      expect(Location.count).to eq(2)
      location = Location.last
      expect(location.building).to eq("Firestone Library")
      expect(location.admin_assistant.id).to eq(staff_profile.id)
      file.unlink
    end

    it "parses the config and updates the aa on an existing building" do
      file = Tempfile.new("locations.yml")
      file.write("- building: #{staff_profile.location.building}\n")
      file.write("  admin_assistant: #{user.uid}\n")
      file.rewind
      file.close
      described_class.load(config_file: file.path)
      expect(Location.count).to eq(1)
      location = Location.last
      expect(location.building).to eq(staff_profile.location.building)
      expect(location.admin_assistant.id).to eq(staff_profile.id)
      file.unlink
    end

    it "parses the config and ignores the bad aa" do
      file = Tempfile.new("locations.yml")
      file.write("- building: Firestone Library\n")
      file.write("  admin_assistant: abc123\n")
      file.rewind
      file.close
      described_class.load(config_file: file.path)
      location = Location.last
      expect(location.building).to eq("Firestone Library")
      expect(location.admin_assistant).to be_nil
      file.unlink
    end
  end
end
