# frozen_string_literal: true
require "rails_helper"

RSpec.describe TravelRequestChangeSet, type: :model do
  subject(:travel_request) { described_class.new(TravelRequest.new) }
  let(:recurring_event) { FactoryBot.create :recurring_event }
  let(:travel_request_errors) do
    {
      creator_id: ["can't be blank"]
    }
  end

  describe "attributes relevant to absence requests" do
    it { is_expected.to respond_to :travel_category }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :notes }
    it { is_expected.to respond_to :purpose }
    it { is_expected.to respond_to :participation }
    it { is_expected.to respond_to :estimates }
  end

  describe "#validate" do
    context "with valid params" do
      let(:valid_params) do
        {
          travel_category: "business", creator_id: 1,
          event_requests: [recurring_event_id: recurring_event.id, start_date: Time.zone.now, location: "Kalamazoo"]
        }
      end

      it "is valid" do
        expect(travel_request.validate(valid_params)).to be_truthy
      end
    end

    context "with empty params" do
      let(:errors) { travel_request_errors.merge(event_requests: ["can't be blank"]) }

      it "is not valid" do
        travel_request.validate({})
        expect(travel_request.errors.messages).to eq(errors)
      end
    end

    context "with missing event_request params" do
      let(:errors) do
        travel_request_errors.merge(
          "event_requests.location": ["can't be blank"],
          "event_requests.start_date": ["can't be blank"]
        )
      end

      it "is not valid" do
        travel_request.validate(event_requests: [recurring_event_id: recurring_event.id])
        expect(travel_request.errors.messages).to eq(errors)
      end
    end

    context "with missing event_request recurring event" do
      let(:errors) { travel_request_errors.merge("event_requests.recurring_event_id": ["can't be blank"]) }

      it "is not valid" do
        travel_request.validate(event_requests: [location: "Kalamazoo", start_date: Time.zone.now])
        expect(travel_request.errors.messages).to eq(errors)
      end
    end

    context "with invalid event_request recurring event" do
      let(:errors) { travel_request_errors.merge("event_requests.recurring_event_id": ["must be a RecurringEvent"]) }

      it "is not valid" do
        travel_request.validate(event_requests: [recurring_event_id: 500, location: "Kalamazoo", start_date: Time.zone.now])
        expect(travel_request.errors.messages).to eq(errors)
      end
    end
  end
end
