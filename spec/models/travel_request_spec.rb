# frozen_string_literal: true
require "rails_helper"

RSpec.describe TravelRequest, type: :model do
  subject(:travel_request) { described_class.new }
  describe "attributes relevant to travel requests" do
    it { is_expected.to respond_to :creator }
    it { is_expected.to respond_to :status }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :request_type }
    it { is_expected.to respond_to :purpose }
    it { is_expected.to respond_to :participation }
    it { is_expected.to respond_to :event_requests }
    it { is_expected.to respond_to :travel_category }
    it { is_expected.to respond_to :notes }
    it { is_expected.to respond_to :estimates }
    it { is_expected.to respond_to :event_title }
  end

  # This acts as a "master test" for all request types using this property
  #
  # Most attributes are tested on the controller, but status will never be set
  # by form (see https://github.com/pulibrary/approvals/issues/112)
  # so test here on the model. Maybe replace with other controller tests
  # when we work that ticket.
  describe "status enum" do
    subject(:travel_request) { FactoryBot.build(:travel_request) }
    it "set expected values" do
      travel_request.pending!
      expect(travel_request.pending?).to eq true
      travel_request.approved!
      expect(travel_request.approved?).to eq true
      travel_request.denied!
      expect(travel_request.denied?).to eq true
      travel_request.changes_requested!
      expect(travel_request.changes_requested?).to eq true
      travel_request.canceled!
      expect(travel_request.canceled?).to eq true
      travel_request.reported!
      expect(travel_request.reported?).to eq true
      travel_request.pending_cancelation!
      expect(travel_request.pending_cancelation?).to eq true
    end
    it "errors for invalid values" do
      expect { travel_request.status = "invalid_status" }.to raise_error ArgumentError
    end
  end

  describe "#id" do
    it "id is greater than ten thousand" do
      expect(FactoryBot.create(:absence_request).id).to be > 10_000
    end
  end
end
