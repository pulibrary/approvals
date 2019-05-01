require "rails_helper"

RSpec.describe Note, type: :model do
  describe "attributes" do
    subject(:note) { described_class.new }
    it { is_expected.to respond_to :creator }
    it { is_expected.to respond_to :content }
    it { is_expected.to respond_to :request }
  end
end
