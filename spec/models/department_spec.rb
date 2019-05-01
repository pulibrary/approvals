require "rails_helper"

RSpec.describe Department, type: :model do
  describe "attributes" do
    subject(:department) { described_class.new }
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :head_id }
    it { is_expected.to respond_to :admin_assistant_id }
    # TODO: this should also repsond to head & admin_assistant once the connection is made
    # it { is_expected.to respond_to :head }
    # it { is_expected.to respond_to :admin_assistant }
  end
end
