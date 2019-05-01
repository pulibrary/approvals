require "rails_helper"

RSpec.describe EventRequest, type: :model do
  describe "attributes" do
    subject(:event_request) { described_class.new }
    it { is_expected.to respond_to :recurring_event }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :location }
    it { is_expected.to respond_to :url }
    it { is_expected.to respond_to :request }
  end
end
