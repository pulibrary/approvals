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
end
