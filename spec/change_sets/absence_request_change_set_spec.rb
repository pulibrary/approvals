# frozen_string_literal: true
require "rails_helper"

RSpec.describe AbsenceRequestChangeSet, type: :model do
  subject(:absence_request) { described_class.new(AbsenceRequest.new) }

  describe "attributes relevant to absence requests" do
    it { is_expected.to respond_to :absence_type }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :notes }
    it { is_expected.to respond_to :start_time }
    it { is_expected.to respond_to :end_time }
  end

  describe "#start_time" do
    it "defaults to 8:45 AM" do
      absence_request.prepopulate!
      expect(absence_request.start_time).to eq Time.zone.parse("8:45 AM")
    end
  end

  describe "#end_time" do
    it "defaults to 5:00 PM" do
      absence_request.prepopulate!
      expect(absence_request.end_time).to eq Time.zone.parse("5:00 PM")
    end
  end

  describe "#time_options" do
    it "provides all times on the quarter hour" do
      expect(absence_request.time_options).to eq(
        "["\
        "{label: '12:00 AM', value: '12:00 AM'},"\
        "{label: '12:15 AM', value: '12:15 AM'},"\
        "{label: '12:30 AM', value: '12:30 AM'},"\
        "{label: '12:45 AM', value: '12:45 AM'},"\
        "{label: '1:00 AM', value: '1:00 AM'},"\
        "{label: '1:15 AM', value: '1:15 AM'},"\
        "{label: '1:30 AM', value: '1:30 AM'},"\
        "{label: '1:45 AM', value: '1:45 AM'},"\
        "{label: '2:00 AM', value: '2:00 AM'},"\
        "{label: '2:15 AM', value: '2:15 AM'},"\
        "{label: '2:30 AM', value: '2:30 AM'},"\
        "{label: '2:45 AM', value: '2:45 AM'},"\
        "{label: '3:00 AM', value: '3:00 AM'},"\
        "{label: '3:15 AM', value: '3:15 AM'},"\
        "{label: '3:30 AM', value: '3:30 AM'},"\
        "{label: '3:45 AM', value: '3:45 AM'},"\
        "{label: '4:00 AM', value: '4:00 AM'},"\
        "{label: '4:15 AM', value: '4:15 AM'},"\
        "{label: '4:30 AM', value: '4:30 AM'},"\
        "{label: '4:45 AM', value: '4:45 AM'},"\
        "{label: '5:00 AM', value: '5:00 AM'},"\
        "{label: '5:15 AM', value: '5:15 AM'},"\
        "{label: '5:30 AM', value: '5:30 AM'},"\
        "{label: '5:45 AM', value: '5:45 AM'},"\
        "{label: '6:00 AM', value: '6:00 AM'},"\
        "{label: '6:15 AM', value: '6:15 AM'},"\
        "{label: '6:30 AM', value: '6:30 AM'},"\
        "{label: '6:45 AM', value: '6:45 AM'},"\
        "{label: '7:00 AM', value: '7:00 AM'},"\
        "{label: '7:15 AM', value: '7:15 AM'},"\
        "{label: '7:30 AM', value: '7:30 AM'},"\
        "{label: '7:45 AM', value: '7:45 AM'},"\
        "{label: '8:00 AM', value: '8:00 AM'},"\
        "{label: '8:15 AM', value: '8:15 AM'},"\
        "{label: '8:30 AM', value: '8:30 AM'},"\
        "{label: '8:45 AM', value: '8:45 AM'},"\
        "{label: '9:00 AM', value: '9:00 AM'},"\
        "{label: '9:15 AM', value: '9:15 AM'},"\
        "{label: '9:30 AM', value: '9:30 AM'},"\
        "{label: '9:45 AM', value: '9:45 AM'},"\
        "{label: '10:00 AM', value: '10:00 AM'},"\
        "{label: '10:15 AM', value: '10:15 AM'},"\
        "{label: '10:30 AM', value: '10:30 AM'},"\
        "{label: '10:45 AM', value: '10:45 AM'},"\
        "{label: '11:00 AM', value: '11:00 AM'},"\
        "{label: '11:15 AM', value: '11:15 AM'},"\
        "{label: '11:30 AM', value: '11:30 AM'},"\
        "{label: '11:45 AM', value: '11:45 AM'},"\
        "{label: '12:00 PM', value: '12:00 PM'},"\
        "{label: '12:15 PM', value: '12:15 PM'},"\
        "{label: '12:30 PM', value: '12:30 PM'},"\
        "{label: '12:45 PM', value: '12:45 PM'},"\
        "{label: '1:00 PM', value: '1:00 PM'},"\
        "{label: '1:15 PM', value: '1:15 PM'},"\
        "{label: '1:30 PM', value: '1:30 PM'},"\
        "{label: '1:45 PM', value: '1:45 PM'},"\
        "{label: '2:00 PM', value: '2:00 PM'},"\
        "{label: '2:15 PM', value: '2:15 PM'},"\
        "{label: '2:30 PM', value: '2:30 PM'},"\
        "{label: '2:45 PM', value: '2:45 PM'},"\
        "{label: '3:00 PM', value: '3:00 PM'},"\
        "{label: '3:15 PM', value: '3:15 PM'},"\
        "{label: '3:30 PM', value: '3:30 PM'},"\
        "{label: '3:45 PM', value: '3:45 PM'},"\
        "{label: '4:00 PM', value: '4:00 PM'},"\
        "{label: '4:15 PM', value: '4:15 PM'},"\
        "{label: '4:30 PM', value: '4:30 PM'},"\
        "{label: '4:45 PM', value: '4:45 PM'},"\
        "{label: '5:00 PM', value: '5:00 PM'},"\
        "{label: '5:15 PM', value: '5:15 PM'},"\
        "{label: '5:30 PM', value: '5:30 PM'},"\
        "{label: '5:45 PM', value: '5:45 PM'},"\
        "{label: '6:00 PM', value: '6:00 PM'},"\
        "{label: '6:15 PM', value: '6:15 PM'},"\
        "{label: '6:30 PM', value: '6:30 PM'},"\
        "{label: '6:45 PM', value: '6:45 PM'},"\
        "{label: '7:00 PM', value: '7:00 PM'},"\
        "{label: '7:15 PM', value: '7:15 PM'},"\
        "{label: '7:30 PM', value: '7:30 PM'},"\
        "{label: '7:45 PM', value: '7:45 PM'},"\
        "{label: '8:00 PM', value: '8:00 PM'},"\
        "{label: '8:15 PM', value: '8:15 PM'},"\
        "{label: '8:30 PM', value: '8:30 PM'},"\
        "{label: '8:45 PM', value: '8:45 PM'},"\
        "{label: '9:00 PM', value: '9:00 PM'},"\
        "{label: '9:15 PM', value: '9:15 PM'},"\
        "{label: '9:30 PM', value: '9:30 PM'},"\
        "{label: '9:45 PM', value: '9:45 PM'},"\
        "{label: '10:00 PM', value: '10:00 PM'},"\
        "{label: '10:15 PM', value: '10:15 PM'},"\
        "{label: '10:30 PM', value: '10:30 PM'},"\
        "{label: '10:45 PM', value: '10:45 PM'},"\
        "{label: '11:00 PM', value: '11:00 PM'},"\
        "{label: '11:15 PM', value: '11:15 PM'},"\
        "{label: '11:30 PM', value: '11:30 PM'},"\
        "{label: '11:45 PM', value: '11:45 PM'},"\
        "]"
      )
    end
  end

  it "presents the absence type options the way lux wants them" do
    expect(absence_request.absence_type_options).to eq(
      [
        { label: "Vacation", value: "vacation" },
        { label: "Sick", value: "sick" },
        { label: "Personal", value: "personal" },
        { label: "Research days", value: "research_days" },
        { label: "Consulting", value: "consulting" },
        { label: "Jury duty", value: "jury_duty" },
        { label: "Death in family", value: "death_in_family" }
      ]
    )
  end

  describe "#validate" do
    context "with valid params" do
      let(:valid_params) { { absence_type: "vacation", creator_id: 1, hours_requested: 8, start_date: Time.zone.now.to_date.to_s, end_date: Time.zone.tomorrow.to_date.to_s } }

      it "is valid" do
        expect(absence_request.validate(valid_params)).to be_truthy
      end
    end

    context "with invalid params" do
      let(:errors) do
        {
          absence_type: ["is not included in the list"],
          creator_id: ["can't be blank"],
          end_date: ["can't be blank"],
          hours_requested: ["can't be blank"],
          start_date: ["can't be blank"]
        }
      end

      it "is not valid" do
        absence_request.validate({})
        expect(absence_request.errors.messages).to eq(errors)
      end
    end
  end
end
