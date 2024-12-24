# frozen_string_literal: true

require "rails_helper"

RSpec.describe StateChange, type: :model do
  describe "attributes relevant to state_change" do
    subject(:state_change) { described_class.new }

    it { is_expected.to respond_to :agent_id }
    it { is_expected.to respond_to :agent }
    it { is_expected.to respond_to :request }
    it { is_expected.to respond_to :request_id }
    it { is_expected.to respond_to :action }
    it { is_expected.to respond_to :delegate_id }
    it { is_expected.to respond_to :delegate }
  end

  describe "#title" do
    it "returns the title for a canceled request" do
      agent = create(:staff_profile, surname: "Doe", given_name: "Jane")
      state_change = create(:state_change, action: "canceled", agent: agent)
      expect(state_change.title).to start_with("Canceled by Jane Doe")
    end

    it "returns the title for a fixed request" do
      agent = create(:staff_profile, :with_department, surname: "Doe", given_name: "Jane")
      request = create(:travel_request, creator: agent, action: "fix_requested_changes")
      state_change = request.state_changes.last
      expect(state_change.title).to start_with("Updated by Jane Doe")
    end
  end
end
