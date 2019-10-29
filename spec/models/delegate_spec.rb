# frozen_string_literal: true
require "rails_helper"

RSpec.describe Delegate, type: :model do
  describe "attributes of a delegate" do
    subject { described_class.new }
    it { is_expected.to respond_to :delegate_id }
    it { is_expected.to respond_to :delegate }
    it { is_expected.to respond_to :delegator_id }
    it { is_expected.to respond_to :delegator }
  end
end
