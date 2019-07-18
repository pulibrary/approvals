# frozen_string_literal: true
require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe AbsenceRequestDecorator, type: :model do
  subject(:absence_request_decorator) { described_class.new(absence_request) }
  let(:absence_request) { FactoryBot.create(:absence_request, absence_type: :vacation) }

  describe "attributes relevant to AbsenceRequest" do
    it { is_expected.to respond_to :absence_type }
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :id }
    it { is_expected.to respond_to :request_type }
    it { is_expected.to respond_to :state_changes }
    it { is_expected.to respond_to :status }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :to_model }
  end

  describe "#absence_type_icon" do
    context "when absence_type is vacation" do
      it "returns vacation icon" do
        expect(absence_request_decorator.absence_type_icon).to eq "lux-icon-vacation"
      end
    end
    context "when absence_type is sick" do
      let(:absence_request) { FactoryBot.create(:absence_request, absence_type: :sick) }
      it "returns sick icon" do
        expect(absence_request_decorator.absence_type_icon).to eq "lux-icon-hospital"
      end
    end
    context "when absence_type is personal" do
      let(:absence_request) { FactoryBot.create(:absence_request, absence_type: :personal) }
      it "returns personal icon" do
        expect(absence_request_decorator.absence_type_icon).to eq "lux-icon-relax"
      end
    end
    context "when absence_type is research_days" do
      let(:absence_request) { FactoryBot.create(:absence_request, absence_type: :research_days) }
      it "returns research_days icon" do
        expect(absence_request_decorator.absence_type_icon).to eq "lux-icon-research"
      end
    end
    context "when absence_type is work_from_home" do
      let(:absence_request) { FactoryBot.create(:absence_request, absence_type: :work_from_home) }
      it "returns work_from_home icon" do
        expect(absence_request_decorator.absence_type_icon).to eq "lux-icon-user-home"
      end
    end
    context "when absence_type is consulting" do
      let(:absence_request) { FactoryBot.create(:absence_request, absence_type: :consulting) }
      it "returns consulting icon" do
        expect(absence_request_decorator.absence_type_icon).to eq "lux-icon-consulting"
      end
    end
    context "when absence_type is jury_duty" do
      let(:absence_request) { FactoryBot.create(:absence_request, absence_type: :jury_duty) }
      it "returns jury_duty icon" do
        expect(absence_request_decorator.absence_type_icon).to eq "lux-icon-scales"
      end
    end
    context "when absence_type is death_in_family" do
      let(:absence_request) { FactoryBot.create(:absence_request, absence_type: :death_in_family) }
      it "returns death_in_family icon" do
        expect(absence_request_decorator.absence_type_icon).to eq "lux-icon-flower"
      end
    end
  end

  describe "#title" do
    context "when absence_type is vacation" do
      it "returns appropriate title" do
        expect(absence_request_decorator.title).to eq "Vacation"
      end
    end
    context "when absence_type is sick" do
      let(:absence_request) { FactoryBot.create(:absence_request, absence_type: :sick) }
      it "returns appropriate title" do
        expect(absence_request_decorator.title).to eq "Sick Leave"
      end
    end
    context "when absence_type is personal days" do
      let(:absence_request) { FactoryBot.create(:absence_request, absence_type: "personal") }
      it "returns appropriate title" do
        expect(absence_request_decorator.title).to eq "Personal Days"
      end
    end
    context "when absence_type is research days" do
      let(:absence_request) { FactoryBot.create(:absence_request, absence_type: :research_days) }
      it "returns appropriate title" do
        expect(absence_request_decorator.title).to eq "Research Days"
      end
    end
    context "when absence type is work from home" do
      let(:absence_request) { FactoryBot.create(:absence_request, absence_type: :work_from_home) }
      it "returns appropriate title" do
        expect(absence_request_decorator.title).to eq "Work From Home Time"
      end
    end
    context "when absence_type is consulting" do
      let(:absence_request) { FactoryBot.create(:absence_request, absence_type: :consulting) }
      it "returns appropriate title" do
        expect(absence_request_decorator.title).to eq "Consulting Leave"
      end
    end
    context "when absence_type is jury duty" do
      let(:absence_request) { FactoryBot.create(:absence_request, absence_type: :jury_duty) }
      it "returns appropriate title" do
        expect(absence_request_decorator.title).to eq "Jury Duty Leave"
      end
    end
    context "when absence type is death in family" do
      let(:absence_request) { FactoryBot.create(:absence_request, absence_type: :death_in_family) }
      it "returns appropriate title" do
        expect(absence_request_decorator.title).to eq "Death In The Family Leave"
      end
    end
  end

  describe "#formatted_start_date" do
    let(:absence_request) { FactoryBot.create(:absence_request, start_date: Time.zone.parse("2019-07-04 12:12")) }
    it "returns a formated start date" do
      expect(absence_request_decorator.formatted_start_date).to eq "Jul 4, 2019"
    end
  end

  describe "#formatted_end_date" do
    let(:absence_request) { FactoryBot.create(:absence_request, end_date: Time.zone.parse("2019-07-04 12:12")) }
    it "returns a formated end date" do
      expect(absence_request_decorator.formatted_end_date).to eq "Jul 4, 2019"
    end
  end

  describe "#status_icon" do
    let(:absence_request) { FactoryBot.create(:absence_request) }
    it "returns the correct lux icon" do
      expect(absence_request_decorator.status_icon).to eq "lux-icon-clock"
    end

    context "when absence has been apporved" do
      let(:absence_request) { FactoryBot.create(:absence_request, status: :approved) }
      it "returns the correct lux icon" do
        expect(absence_request_decorator.status_icon).to eq "lux-icon-approved"
      end
    end

    context "when absence has been denied" do
      let(:absence_request) { FactoryBot.create(:absence_request, status: :denied) }
      it "returns the correct lux icon" do
        expect(absence_request_decorator.status_icon).to eq "lux-icon-denied"
      end
    end

    context "when absence has had changes_requested" do
      let(:absence_request) { FactoryBot.create(:absence_request, status: :changes_requested) }
      it "returns the correct lux icon" do
        expect(absence_request_decorator.status_icon).to eq "lux-icon-alert"
      end
    end

    context "when absence has been canceled" do
      let(:absence_request) { FactoryBot.create(:absence_request, status: :canceled) }
      it "returns the correct lux icon" do
        expect(absence_request_decorator.status_icon).to eq "lux-icon-alert"
      end
    end

    context "when absence has been recorded" do
      let(:absence_request) { FactoryBot.create(:absence_request, status: :recorded) }
      it "returns the correct lux icon" do
        expect(absence_request_decorator.status_icon).to eq "lux-icon-file"
      end
    end

    context "when absence is pending cancelation" do
      let(:absence_request) { FactoryBot.create(:absence_request, status: :pending_cancelation) }
      it "returns the correct lux icon" do
        expect(absence_request_decorator.status_icon).to eq "lux-icon-flower"
      end
    end
  end

  describe "#latest_status" do
    let(:absence_request) { FactoryBot.create(:absence_request, status: :canceled) }
    let(:today) { Time.zone.now }
    it "returns the last created status and date" do
      FactoryBot.create :state_change, request: absence_request, action: :approved
      FactoryBot.create :state_change, request: absence_request, action: :canceled
      expect(absence_request_decorator.latest_status).to eq "Canceled on #{today.strftime('%b %-d, %Y')}"
    end
  end
end
