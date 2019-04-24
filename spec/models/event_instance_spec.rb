require 'rails_helper'

RSpec.describe EventInstance, type: :model do
  describe "attributes" do
    subject(:event_instance) { described_class.new }
    it { is_expected.to respond_to :event }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :location }
    it { is_expected.to respond_to :url }
  end
end
