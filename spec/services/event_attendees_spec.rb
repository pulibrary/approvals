# frozen_string_literal: true
require "rails_helper"

RSpec.describe EventAttendees, type: :model do
  let(:jack) { FactoryBot.create :staff_profile, given_name: "Jack" }
  let(:jill) { FactoryBot.create :staff_profile, given_name: "Jill" }
  let(:mary) { FactoryBot.create :staff_profile, given_name: "Mary" }
  let(:peter) { FactoryBot.create :staff_profile, given_name: "Peter" }
  let(:hill) { FactoryBot.create :recurring_event }
  let(:peppers) { FactoryBot.create :recurring_event }
  let(:garden) { FactoryBot.create :recurring_event }
  let(:mary_garden_2020) do
    start_date = Time.zone.now + 1.year
    end_date = start_date + 2.days
    event_request = FactoryBot.build :event_request, recurring_event: garden, start_date: start_date, end_date: end_date
    FactoryBot.create :travel_request, creator: mary, event_requests: [event_request], start_date: start_date - 1.day, end_date: end_date
  end
  let(:mary_garden_2019) do
    start_date = Time.zone.now
    end_date = start_date + 3.days
    event_request = FactoryBot.build :event_request, recurring_event: garden, start_date: start_date, end_date: end_date
    FactoryBot.create :travel_request, creator: mary, event_requests: [event_request], start_date: start_date - 1.day, end_date: end_date
  end
  let(:jill_garden_2018) do
    start_date = Time.zone.now - 1.year
    end_date = start_date + 2.days
    event_request = FactoryBot.build :event_request, recurring_event: garden, start_date: start_date, end_date: end_date
    FactoryBot.create :travel_request, creator: jill, event_requests: [event_request], start_date: start_date - 1.day, end_date: end_date
  end
  let(:peter_peppers_2019) do
    start_date = Time.zone.now
    end_date = start_date + 5.days
    event_request = FactoryBot.build :event_request, recurring_event: peppers, start_date: start_date, end_date: end_date
    FactoryBot.create :travel_request, creator: peter, event_requests: [event_request], start_date: start_date - 1.day, end_date: end_date
  end
  let(:jack_hill_2019) do
    start_date = Time.zone.now
    end_date = start_date + 5.days
    event_request = FactoryBot.build :event_request, recurring_event: hill, start_date: start_date, end_date: end_date
    FactoryBot.create :travel_request, creator: jack, event_requests: [event_request], start_date: start_date - 1.day, end_date: end_date
  end
  let(:jill_hill_2019) do
    start_date = Time.zone.now
    end_date = start_date + 5.days
    event_request = FactoryBot.build :event_request, recurring_event: hill, start_date: start_date, end_date: end_date
    FactoryBot.create :travel_request, creator: jill, event_requests: [event_request], start_date: start_date - 1.day, end_date: end_date
  end

  before do
    jill_garden_2018
    mary_garden_2019
    peter_peppers_2019
    jack_hill_2019
    jill_hill_2019
    mary_garden_2020
  end

  describe "#list" do
    it "returns attendees" do
      expect(described_class.list(recurring_event: garden, event_start_date: Time.zone.now)).to contain_exactly(mary)
      expect(described_class.list(recurring_event: hill, event_start_date: Time.zone.now)).to contain_exactly(jack, jill)
      expect(described_class.list(recurring_event: peppers, event_start_date: Time.zone.now)).to contain_exactly(peter)
    end

    context "date is within a week" do
      it "returns attendees" do
        expect(described_class.list(recurring_event: garden, event_start_date: Time.zone.now - 5.days)).to contain_exactly(mary)
        expect(described_class.list(recurring_event: garden, event_start_date: Time.zone.now - 7.days)).to contain_exactly(mary)
        expect(described_class.list(recurring_event: garden, event_start_date: Time.zone.now + 5.days)).to contain_exactly(mary)
        expect(described_class.list(recurring_event: garden, event_start_date: Time.zone.now + 7.days)).to contain_exactly(mary)
      end
    end

    context "date does not match" do
      it "returns no attendees" do
        expect(described_class.list(recurring_event: garden, event_start_date: Time.zone.now - 8.days)).to be_empty
        expect(described_class.list(recurring_event: garden, event_start_date: Time.zone.now - 1.month)).to be_empty
        expect(described_class.list(recurring_event: garden, event_start_date: Time.zone.now + 8.days)).to be_empty
        expect(described_class.list(recurring_event: garden, event_start_date: Time.zone.now + 1.month)).to be_empty
      end
    end

    context "changing the window" do
      it "returns the right attendees" do
        expect(described_class.list(recurring_event: garden, event_start_date: Time.zone.now - 4.days, window: 5.days)).to contain_exactly(mary)
        expect(described_class.list(recurring_event: garden, event_start_date: Time.zone.now - 4.days, window: 3.days)).to be_empty
        expect(described_class.list(recurring_event: garden, event_start_date: Time.zone.now + 4.days, window: 5.days)).to contain_exactly(mary)
        expect(described_class.list(recurring_event: garden, event_start_date: Time.zone.now + 4.days, window: 3.days)).to be_empty
      end
    end
  end
end
