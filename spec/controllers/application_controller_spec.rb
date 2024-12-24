# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController do
  let(:request) { ActionDispatch::Request.new({}) }

  describe "#new_session_path" do
    it "returns the new session path" do
      controller = described_class.new
      allow(controller).to receive(:request).and_return(request)
      expect(controller.new_session_path(nil)).to eq("/sign_in")
    end
  end

  describe "#current_delegate" do
    it "returns a good delegate" do
      controller = described_class.new
      current_user = create(:staff_profile)
      delegate_staff_profile = create(:staff_profile)
      delegate = create(:delegate, delegator: delegate_staff_profile, delegate: current_user)
      allow(controller).to receive(:session).and_return(approvals_delegate: delegate.id)
      allow(controller).to receive(:current_user).and_return(current_user.user)
      expect(controller.current_delegate).to eq(delegate)
    end

    it "returns nil for a bad delegate" do
      controller = described_class.new
      allow(controller).to receive(:session).and_return(approvals_delegate: "abc")
      expect(controller.current_delegate).to be_nil
    end

    it "returns nil for a delegate that does not include the current_user" do
      controller = described_class.new
      current_user = create(:staff_profile)
      staff_profile = create(:staff_profile)
      delegate_staff_profile = create(:staff_profile)
      delegate = create(:delegate, delegator: delegate_staff_profile, delegate: staff_profile)
      allow(controller).to receive(:session).and_return(approvals_delegate: delegate.id)
      allow(controller).to receive(:current_user).and_return(current_user)
      expect(controller.current_delegate).to be_nil
    end
  end
end
