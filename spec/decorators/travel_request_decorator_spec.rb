require "rails_helper"

RSpec.describe TravelRequestDecorator, type: :model do
  subject(:travel_request_decorator) { described_class.new(travel_request) }
  let(:travel_request) { FactoryBot.create(:travel_request) }

  describe "attributes relevant to TravelRequest" do
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :id }
    it { is_expected.to respond_to :request_type }
    it { is_expected.to respond_to :status }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :to_model }
    it { is_expected.to respond_to :travel_category }
  end

  describe "#travel_category_icon" do
    context "when travel_category is None" do
      it "returns the correct lux icon" do
        expect(travel_request_decorator.travel_category_icon).to eq "lux-icon-clock"
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
        expect(travel_request_decorator.travel_category_icon).to eq "lux-icon-picture"
      end
    end
    context "when travel_category is discretionary" do
      let(:travel_request) { FactoryBot.create(:travel_request, travel_category: :discretionary) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.travel_category_icon).to eq "lux-icon-relax"
      end
    end
  end

  describe "#title" do
    context "when travel_category is empty" do
      it "returns appropriate title" do
        expect(travel_request_decorator.title).to eq "Uncategorized travel"
      end
    end
    context "when travel_category is business" do
      let(:travel_request) { FactoryBot.create(:travel_request, travel_category: :business) }
      it "returns appropriate title" do
        expect(travel_request_decorator.title).to eq "Business"
      end
    end
    context "when travel_category is professional development" do
      let(:travel_request) { FactoryBot.create(:travel_request, travel_category: :professional_development) }
      it "returns appropriate title" do
        expect(travel_request_decorator.title).to eq "Professional development"
      end
    end
    context "when travel_category is discretionary" do
      let(:travel_request) { FactoryBot.create(:travel_request, travel_category: :discretionary) }
      it "returns appropriate title" do
        expect(travel_request_decorator.title).to eq "Discretionary"
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

    context "when travel has been apporved" do
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
        expect(travel_request_decorator.status_icon).to eq "lux-icon-alert"
      end
    end
  end
end
