# frozen_string_literal: true
require "rails_helper"

RSpec.describe CombineRecurringEvents, type: :model do
  describe "#process" do
    it "throws no errors when zero events are passed" do
      described_class.process(combined_name: "Developer Congress", selected_event_ids: [])
    end

    it "does nothing for one event" do
      event1 = FactoryBot.create :recurring_event, name: "Dev Congress"
      FactoryBot.create :travel_request, event_requests: [FactoryBot.build(:event_request, recurring_event: event1)]
      described_class.process(combined_name: "Developer Congress", selected_event_ids: [event1.id])
      expect(EventRequest.where(recurring_event: event1).count).to eq(1)
    end

    it "combines two events" do
      event1 = FactoryBot.create :recurring_event, name: "Dev Congress"
      event2 = FactoryBot.create :recurring_event, name: "Developer congress"
      FactoryBot.create :travel_request, event_requests: [FactoryBot.build(:event_request, recurring_event: event1)]
      FactoryBot.create :travel_request, event_requests: [FactoryBot.build(:event_request, recurring_event: event2)]
      described_class.process(combined_name: "Developer Congress", selected_event_ids: [event1.id, event2.id])
      expect(EventRequest.where(recurring_event: event1).count).to eq(2)
      expect(RecurringEvent.find_by(id: event2)).to be_nil
    end

    it "combines three events" do
      event1 = FactoryBot.create :recurring_event, name: "Dev Congress"
      event2 = FactoryBot.create :recurring_event, name: "Developer congress"
      event3 = FactoryBot.create :recurring_event, name: "Dev congress"
      FactoryBot.create :travel_request, event_requests: [FactoryBot.build(:event_request, recurring_event: event1)]
      FactoryBot.create :travel_request, event_requests: [FactoryBot.build(:event_request, recurring_event: event1)]
      FactoryBot.create :travel_request, event_requests: [FactoryBot.build(:event_request, recurring_event: event2)]
      FactoryBot.create :travel_request, event_requests: [FactoryBot.build(:event_request, recurring_event: event2)]
      FactoryBot.create :travel_request, event_requests: [FactoryBot.build(:event_request, recurring_event: event2)]
      expect(EventRequest.where(recurring_event: event1).count).to eq(2)
      expect(EventRequest.where(recurring_event: event2).count).to eq(3)
      expect(EventRequest.where(recurring_event: event3).count).to eq(0)
      described_class.process(combined_name: "Developer Congress", selected_event_ids: [event1.id, event2.id, event3.id])
      expect(EventRequest.where(recurring_event: event1).count).to eq(5)
      expect(RecurringEvent.find_by(id: event2)).to be_nil
      expect(RecurringEvent.find_by(id: event3)).to be_nil
    end
  end
end
