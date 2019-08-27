# frozen_string_literal: true
require "rails_helper"

RSpec.describe Estimate, type: :model do
  describe "attributes" do
    subject(:estimate) { described_class.new }
    it { is_expected.to respond_to :request }
    it { is_expected.to respond_to :cost_type }
    it { is_expected.to respond_to :amount }
    it { is_expected.to respond_to :recurrence }
    it { is_expected.to respond_to :description }
  end
end
