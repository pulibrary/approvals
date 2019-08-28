# frozen_string_literal: true
require "rails_helper"

RSpec.describe TravelRequestDecorator, type: :model do
  subject(:travel_request_decorator) { described_class.new(travel_request) }
  let(:travel_request) { FactoryBot.create(:travel_request) }

  describe "attributes relevant to TravelRequest" do
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :id }
    it { is_expected.to respond_to :request_type }
    it { is_expected.to respond_to :state_changes }
    it { is_expected.to respond_to :status }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :to_model }
    it { is_expected.to respond_to :travel_category }
  end

  describe "#travel_category_icon" do
    context "when travel_category is None" do
      it "returns the correct lux icon" do
        expect(travel_request_decorator.travel_category_icon).to eq "lux-icon-globe"
      end
    end
    context "when travel_category is Business" do
      let(:travel_request) { FactoryBot.create(:travel_request, travel_category: :business) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.travel_category_icon).to eq "lux-icon-globe"
      end
    end
    context "when travel_category is professional development" do
      let(:travel_request) { FactoryBot.create(:travel_request, travel_category: :professional_development) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.travel_category_icon).to eq "lux-icon-globe"
      end
    end
    context "when travel_category is discretionary" do
      let(:travel_request) { FactoryBot.create(:travel_request, travel_category: :discretionary) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.travel_category_icon).to eq "lux-icon-globe"
      end
    end
  end

  describe "#formatted_start_date" do
    let(:travel_request) { FactoryBot.create(:travel_request, start_date: Time.zone.parse("2019-07-04 12:12")) }
    it "returns a formated start date" do
      expect(travel_request_decorator.formatted_start_date).to eq "Jul 4, 2019"
    end
  end

  describe "#formatted_end_date" do
    let(:travel_request) { FactoryBot.create(:travel_request, end_date: Time.zone.parse("2019-07-04 12:12")) }
    it "returns a formated end date" do
      expect(travel_request_decorator.formatted_end_date).to eq "Jul 4, 2019"
    end
  end

  describe "#status_icon" do
    let(:travel_request) { FactoryBot.create(:travel_request) }
    it "returns the correct lux icon" do
      expect(travel_request_decorator.status_icon).to eq "lux-icon-clock"
    end

    context "when travel has been approved" do
      let(:travel_request) { FactoryBot.create(:travel_request, status: :approved) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.status_icon).to eq "lux-icon-approved"
      end
    end

    context "when travel has been denied" do
      let(:travel_request) { FactoryBot.create(:travel_request, status: :denied) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.status_icon).to eq "lux-icon-denied"
      end
    end

    context "when travel has been changes_requested" do
      let(:travel_request) { FactoryBot.create(:travel_request, status: :changes_requested) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.status_icon).to eq "lux-icon-refresh"
      end
    end

    context "when travel has been canceled" do
      let(:travel_request) { FactoryBot.create(:travel_request, status: :canceled) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.status_icon).to eq "lux-icon-alert"
      end
    end
  end

  describe "#latest_status" do
    let(:travel_request) { FactoryBot.create(:travel_request) }
    let(:today) { Time.zone.now }
    it "returns the status and the createddate" do
      expect(travel_request_decorator.latest_status).to eq "Pending on #{today.strftime('%b %-d, %Y')}"
    end

    context "it has been approved and then canceled" do
      let(:travel_request) { FactoryBot.create(:travel_request, status: :canceled) }
      it "returns the last created status and date" do
        FactoryBot.create :state_change, request: travel_request, action: :approved
        FactoryBot.create :state_change, request: travel_request, action: :canceled
        expect(travel_request_decorator.latest_status).to eq "Canceled on #{today.strftime('%b %-d, %Y')}"
      end
    end

    context "approved but waiting on further approval" do
      let(:travel_request) { FactoryBot.create(:travel_request, status: :pending) }
      it "returns pending futher approval" do
        FactoryBot.create :state_change, request: travel_request, action: :approved
        expect(travel_request_decorator.latest_status).to eq "Pending further approval on #{today.strftime('%b %-d, %Y')}"
      end
    end
  end

  describe "#estimates_json" do
    it "returns json data" do
      expect(travel_request_decorator.estimates_json).to eq '[{"cost_type":"","note":"","recurrence":"","amount":"Total:","total":"0.00"}]'
    end

    context "with estimate" do
      let(:travel_request) { FactoryBot.create(:travel_request, :with_note_and_estimate) }
      it "returns json data" do
        expect(travel_request_decorator.estimates_json).to eq(
          '[{"cost_type":"lodging","note":"","recurrence":3,"amount":"50.00","total":"150.00"},' \
          '{"cost_type":"","note":"","recurrence":"","amount":"Total:","total":"150.00"}]'
        )
      end
    end
  end
end
