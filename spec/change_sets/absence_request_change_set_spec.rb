# frozen_string_literal: true
require "rails_helper"

RSpec.describe AbsenceRequestChangeSet, type: :model do
  subject(:absence_request) { described_class.new(AbsenceRequest.new) }

  describe "attributes relevant to absence requests" do
    it { is_expected.to respond_to :absence_type }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :notes }
  end

  it "presents the absence type options the way lux wants them" do
    expect(absence_request.absence_type_options).to eq(
      "["\
      "{label: 'Vacation', value: 'vacation'},"\
      "{label: 'Sick', value: 'sick'},"\
      "{label: 'Personal', value: 'personal'},"\
      "{label: 'Research days', value: 'research_days'},"\
      "{label: 'Work from home', value: 'work_from_home'},"\
      "{label: 'Consulting', value: 'consulting'},"\
      "{label: 'Jury duty', value: 'jury_duty'},"\
      "{label: 'Death in family', value: 'death_in_family'}"\
      "]"
    )
  end

  describe "#validate" do
    context "with valid params" do
      let(:valid_params) { { absence_type: "vacation", creator_id: 1 } }

      it "is valid" do
        expect(absence_request.validate(valid_params)).to be_truthy
      end
    end

    context "with invalid params" do
      let(:errors) do
        {
          absence_type: ["is not included in the list"],
          creator_id: ["can't be blank"]
        }
      end

      it "is valid" do
        absence_request.validate({})
        expect(absence_request.errors.messages).to eq(errors)
      end
    end
  end
end
