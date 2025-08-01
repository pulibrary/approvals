# frozen_string_literal: true

require "rails_helper"
RSpec.describe EstimateDecorator, type: :model do
  subject(:estimate_decorator) { described_class.new(estimate) }

  let(:estimate) { create(:estimate, request:) }
  let(:request) { create(:travel_request) }

  describe "attributes relevant to Estimate" do
    it { is_expected.to respond_to :cost_type }
    it { is_expected.to respond_to :description }
    it { is_expected.to respond_to :recurrence }
    it { is_expected.to respond_to :amount }
  end

  context "with a nil cost_type" do
    let(:estimate) { create(:estimate, cost_type: nil, request:) }

    it "raises an expected error" do
        expect { estimate_decorator.data }.to raise_error(NoMethodError, "undefined method `to_sym' for nil")
    end
  end

  describe "#data" do
    it "returns json data" do
      expect(estimate_decorator.data).to eq(cost_type: "Lodging (per night)", note: "", recurrence: 3, amount: "50.00",
                                            total: "150.00")
    end
  end

  describe "##cost_options_json" do
    it "returns all the options" do
      expect(described_class.cost_options_json).to eq("[{label: 'Airfare', value: 'air'},{label: 'Car rental', value: 'rental_vehicle'},"\
                                                      "{label: 'Ground transportation', value: 'ground_transportation'},{label: 'Lodging (per night)', value: 'lodging'}," \
                                                      "{label: 'Meals and related expenses (daily)', value: 'meals'}," \
                                                      "{label: 'Miscellaneous', value: 'misc'},{label: 'Other transit', value: 'transit_other'}," \
                                                      "{label: 'Parking', value: 'parking'},{label: 'Registration fee', value: 'registration'}," \
                                                      "{label: 'Taxi', value: 'taxi'},{label: 'Train', value: 'train'}]")
    end
  end
end
