# frozen_string_literal: true
require "rails_helper"

RSpec.describe Holidays, type: :model do
  describe "#list" do
    it "parses the config and returns the dates" do
      file = Tempfile.new("holidays.yml")
      file.write("- \"2019-11-28\"\n")
      file.write("- \"2019-11-29\"\n")
      file.write("- \"2019-12-25\"\n")
      file.rewind
      file.close

      expect(Holidays.list(config_file: file.path)).to eq([
                                                            Date.new(2019, 11, 28), Date.new(2019, 11, 29),
                                                            Date.new(2019, 12, 25)
                                                          ])
      file.unlink
    end
  end
end
