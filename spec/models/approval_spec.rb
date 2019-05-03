require "rails_helper"

RSpec.describe Approval, type: :model do
  describe "attributes relevant to approval" do
    subject(:approval) { described_class.new }
    it { is_expected.to respond_to :approver_id }
    it { is_expected.to respond_to :approver }
    it { is_expected.to respond_to :request }
    it { is_expected.to respond_to :request_id }
    it { is_expected.to respond_to :approved }
  end
end
