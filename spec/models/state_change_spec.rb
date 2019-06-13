# frozen_string_literal: true
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

  describe "before_save calculate_new_status" do
    subject(:state_change) { FactoryBot.create :state_change, request: request, action: action, approver: approver }
    let(:approver) { FactoryBot.create :staff_profile }
    context "change applied to an absence request" do
      let(:request) { FactoryBot.create :absence_request }

      context "when stage changes to approved" do
        let(:action) { "approved" }
        it "sets the request status to approved when saved" do
          state_change
          expect(request.reload.status).to eq("approved")
        end
      end

      context "when stage changes to denied" do
        let(:action) { "denied" }
        it "sets the request status to denied when saved" do
          state_change
          expect(request.reload.status).to eq("denied")
        end
      end

      context "when stage changes to reported" do
        let(:action) { "reported" }
        it "sets the request status to reported when saved" do
          state_change
          expect(request.reload.status).to eq("reported")
        end
      end

      context "when stage changes to canceled and it was not already reported" do
        let(:action) { "canceled" }
        it "sets the request status to canceled when saved" do
          state_change
          expect(request.reload.status).to eq("canceled")
        end
      end

      context "when stage changes to canceled and it was already reported" do
        let(:action) { "canceled" }
        let(:request) { FactoryBot.create :absence_request, status: "reported" }

        it "sets the request status to pending_cancelation when saved" do
          state_change
          expect(request.reload.status).to eq("pending_cancelation")
        end
      end
    end
    context "change applied to an travel request" do
      let(:request) { FactoryBot.create :travel_request }

      context "when stage changes to approved and the supervisor is not a department head" do
        let(:action) { "approved" }
        it "sets the request status to pending when saved" do
          state_change
          expect(request.reload.status).to eq("pending")
        end
      end

      context "when stage changes to approved and the supervisor isa department head" do
        let(:action) { "approved" }
        let(:approver) { FactoryBot.create :staff_profile, :as_department_head }
        it "sets the request status to approved when saved" do
          state_change
          expect(request.reload.status).to eq("approved")
        end
      end

      context "when stage changes to denied" do
        let(:action) { "denied" }
        it "sets the request status to denied when saved" do
          state_change
          expect(request.reload.status).to eq("denied")
        end
      end

      context "when stage changes to request changes" do
        let(:action) { "changes_requested" }
        it "sets the request status to changes_requested when saved" do
          state_change
          expect(request.reload.status).to eq("changes_requested")
        end
      end

      context "when stage changes to canceled" do
        let(:action) { "canceled" }
        it "sets the request status to canceled when saved" do
          state_change
          expect(request.reload.status).to eq("canceled")
        end
      end
    end
  end
end
