require "rails_helper"

RSpec.describe TravelRequest, type: :model do
  describe "attributes relevant to travel requests" do
    subject(:travel_request) { described_class.new }
    it { is_expected.to respond_to :creator }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :request_type }
    it { is_expected.to respond_to :purpose }
    it { is_expected.to respond_to :participation }
    it { is_expected.to respond_to :event_requests }
    it { is_expected.to respond_to :travel_category }
    it { is_expected.to respond_to :notes }
    it { is_expected.to respond_to :estimates }
  end
end
