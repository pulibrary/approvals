# frozen_string_literal: true

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

  describe "#destory" do
    it "destroys dependants" do
      recurring_event = create(:recurring_event, name: "Ice Capades")
      travel_request = create(:travel_request, action: :approve)
      create(:event_request, recurring_event: recurring_event, request: travel_request)
      expect { recurring_event.destroy }.to change(EventRequest, :count).by(-1)
    end
  end
end
