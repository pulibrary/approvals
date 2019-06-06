require "rails_helper"

RSpec.describe StateChange, type: :model do
  describe "attributes relevant to state_change" do
    subject(:state_change) { described_class.new }
    it { is_expected.to respond_to :approver_id }
    it { is_expected.to respond_to :approver }
    it { is_expected.to respond_to :request }
    it { is_expected.to respond_to :request_id }
    it { is_expected.to respond_to :action }
  end
end
