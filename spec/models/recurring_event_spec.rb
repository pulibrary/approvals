require "rails_helper"

RSpec.describe RecurringEvent, type: :model do
  describe "attributes" do
    subject(:recurring_event) { described_class.new }
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :description }
    it { is_expected.to respond_to :url }
    it { is_expected.to respond_to :event_requests }
    it { is_expected.to respond_to :requests }
  end
end