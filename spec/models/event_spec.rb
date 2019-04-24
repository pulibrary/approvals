require 'rails_helper'

RSpec.describe Event, type: :model do
  describe "attributes" do
    subject(:event) { described_class.new }
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :description }
    it { is_expected.to respond_to :url }
    it { is_expected.to respond_to :event_instances }
  end
end
