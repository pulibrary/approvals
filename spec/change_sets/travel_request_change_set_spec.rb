# frozen_string_literal: true

require "rails_helper"

RSpec.describe TravelRequestChangeSet, type: :model do
  subject(:travel_request) { described_class.new(TravelRequest.new) }

  let(:recurring_event) { create(:recurring_event) }
  let(:travel_request_errors) do
    {
      creator_id: ["can't be blank"],
      participation: ["is not included in the list"]
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
          travel_category: "business", creator_id: 1, purpose: "my grand purpose", participation: "presenter",
          event_requests: [recurring_event_id: recurring_event.id, start_date: Time.zone.now, location: "Kalamazoo"]
        }
      end

      it "is valid" do
        expect(travel_request.validate(valid_params)).to be_truthy
      end
    end

    context "with a new Event" do
      let(:valid_params) do
        {
          travel_category: "business", creator_id: 1, purpose: "my grand purpose", participation: "presenter",
          event_requests: [recurring_event_id: "New Event", start_date: Time.zone.now, location: "Kalamazoo"]
        }
      end

      it "is valid" do
        expect do
          expect(travel_request.validate(valid_params)).to be_truthy
          expect(travel_request.validate(valid_params)).to be_truthy
          expect(travel_request.validate(valid_params)).to be_truthy
          expect(travel_request.validate(valid_params)).to be_truthy
        end.to change(RecurringEvent, :count).by(1)
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

  describe "#recurring_event_list" do
    it "responds with recurring events and will calculate new ones only if needed" do
      event1 = create(:recurring_event, name: "abc")
      expect(travel_request.recurring_event_list).to eq("[{\"id\":#{event1.id},\"label\":\"abc\"}]")
      event2 = create(:recurring_event, name: "two")
      expect(travel_request.recurring_event_list).to eq("[{\"id\":#{event1.id},\"label\":\"abc\"},{\"id\":#{event2.id},\"label\":\"two\"}]")
      values_before = travel_request.instance_variable_get(:@values)
      expect(travel_request.recurring_event_list).to eq("[{\"id\":#{event1.id},\"label\":\"abc\"},{\"id\":#{event2.id},\"label\":\"two\"}]")
      values_after = travel_request.instance_variable_get(:@values)
      expect(values_after).to be(values_before)
    end
  end

  describe "#existing_notes" do
    it "gathers existing notes and filters blank notes" do
      travel_request = described_class.new(create(:travel_request))
      travel_request.notes << Note.new
      expect(travel_request.existing_notes).to be_empty
      note = create(:note, request: travel_request.model, content: "My Note")
      travel_request.notes << note
      expect(travel_request.existing_notes).to eq [{ content: "My Note", icon: "note",
                                                     title: "#{note.creator.full_name} on #{note.created_at.strftime(Rails.configuration.short_date_format)}" }]
    end
  end
end
