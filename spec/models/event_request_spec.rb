# frozen_string_literal: true

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

  describe "before_save callback" do
    it "updates the event title of a travel request" do
      recurring_event = create(:recurring_event, name: "Ice Capades")
      creator = create(:staff_profile)
      event_requests_attributes = [
        recurring_event_id: recurring_event.id,
        location: "Beijing",
        start_date: Time.zone.today
      ]

      travel_request = TravelRequest.create(event_requests_attributes:, creator:)
      expect(travel_request.event_title).to eq "Ice Capades #{Time.zone.today.year}, Beijing"
    end
  end
end
