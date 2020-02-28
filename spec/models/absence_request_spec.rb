# frozen_string_literal: true
require "rails_helper"

RSpec.describe AbsenceRequest, type: :model do
  subject(:absence_request) { described_class.new creator: creator }
  let(:creator_user) { FactoryBot.create :user, uid: "ssmith" }
  let(:creator) { FactoryBot.create :staff_profile, given_name: "Sally", surname: "Smith", user: creator_user }
  let(:user) { FactoryBot.create :staff_profile, :with_department }
  describe "attributes relevant to absence requests" do
    it { is_expected.to respond_to :absence_type }
    it { is_expected.to respond_to :creator }
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :end_time }
    it { is_expected.to respond_to :hours_requested }
    it { is_expected.to respond_to :notes }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :start_time }
    it { is_expected.to respond_to :status }
    it { is_expected.to respond_to :pending? }
    it { is_expected.to respond_to :canceled? }
    it { is_expected.to respond_to :approved? }
    it { is_expected.to respond_to :denied? }
    it { is_expected.to respond_to :recorded? }
  end

  describe "#status" do
    it "has a default of pending" do
      expect(absence_request.status).to eq("pending")
    end
  end

  describe "#to_s" do
    it "has a default of pending" do
      expect(absence_request.to_s).to eq("Smith, Sally (ssmith) Absence")
    end
  end

  context "A saved absence request" do
    let(:creator) { FactoryBot.create :staff_profile, :with_department }
    let(:absence_request) { FactoryBot.create :absence_request, creator: creator }
    let(:supervisor) { creator.supervisor }
    let(:department_head) { creator.department.head }

    describe "#approve!" do
      it "approves a pending event if the agent is their supervisor" do
        expect do
          absence_request.approve!(agent: supervisor)
        end.to change(StateChange, :count).by(1)
        expect(absence_request.status).to eq("approved")
        expect(absence_request.persisted?).to be_truthy
      end

      it "approves a pending event if the agent is their department head" do
        expect do
          absence_request.approve!(agent: department_head)
        end.to change(StateChange, :count).by(1)
        expect(absence_request.status).to eq("approved")
        expect(absence_request.persisted?).to be_truthy
      end

      it "Does not approve if the agent is not a supervisor" do
        expect { absence_request.approve!(agent: user) }.to raise_error AASM::InvalidTransition
      end

      it "Does not approve a recorded event" do
        absence_request.approve!(agent: supervisor)
        absence_request.record!(agent: user)
        expect { absence_request.approve!(agent: user) }.to raise_error AASM::InvalidTransition
      end

      it "Does not approve a canceled event" do
        absence_request.cancel!(agent: creator)
        expect { absence_request.approve!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end

      it "Does not approve a denied event" do
        absence_request.deny!(agent: supervisor)
        expect { absence_request.approve!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end
    end

    describe "#deny!" do
      it "does not deny a pending event if you are not a supervisor of the requestor" do
        expect { absence_request.deny!(agent: user) }.to raise_error AASM::InvalidTransition
      end

      it "denies a pending event if the agent is the department head" do
        expect do
          absence_request.deny!(agent: department_head)
        end.to change(StateChange, :count).by(1)
        expect(absence_request.status).to eq("denied")
        expect(absence_request.persisted?).to be_truthy
      end

      it "denies a pending event is the agent is a supervisor" do
        expect do
          absence_request.deny!(agent: supervisor)
        end.to change(StateChange, :count).by(1)
        expect(absence_request.status).to eq("denied")
        expect(absence_request.persisted?).to be_truthy
      end

      it "Does not deny a recorded event" do
        absence_request.approve!(agent: supervisor)
        absence_request.record!(agent: user)
        expect { absence_request.deny!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end

      it "Does not deny a canceled event" do
        absence_request.cancel!(agent: creator)
        expect { absence_request.deny!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end

      it "Does not deny an approved event" do
        absence_request.approve!(agent: supervisor)
        expect { absence_request.deny!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end
    end

    describe "#record!" do
      it "records an approved event" do
        expect do
          absence_request.approve!(agent: supervisor)
          absence_request.record!(agent: user)
        end.to change(StateChange, :count).by(2)
        expect(absence_request.status).to eq("recorded")
        expect(absence_request.persisted?).to be_truthy
      end

      it "Does not record a pending event" do
        expect { absence_request.record!(agent: user) }.to raise_error AASM::InvalidTransition
      end

      it "Does not record a canceled event" do
        absence_request.cancel!(agent: creator)
        expect { absence_request.record!(agent: user) }.to raise_error AASM::InvalidTransition
      end

      it "Does not record a denied event" do
        absence_request.deny!(agent: supervisor)
        expect { absence_request.record!(agent: user) }.to raise_error AASM::InvalidTransition
      end
    end

    describe "#cancel!" do
      it "cancels a pending event" do
        expect do
          absence_request.cancel!(agent: creator)
        end.to change(StateChange, :count).by(1)
        expect(absence_request.status).to eq("canceled")
        expect(absence_request.persisted?).to be_truthy
      end

      it "cancels an approved event" do
        expect do
          absence_request.approve!(agent: supervisor)
          absence_request.cancel!(agent: creator)
        end.to change(StateChange, :count).by(2)
        expect(absence_request.status).to eq("canceled")
        expect(absence_request.persisted?).to be_truthy
      end

      it "does not cancel a recorded event" do
        absence_request.approve!(agent: supervisor)
        absence_request.record!(agent: user)
        expect { absence_request.cancel!(agent: user) }.to raise_error AASM::InvalidTransition
      end

      it "does not cancel an event if it is not the creator requesting" do
        expect { absence_request.cancel!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end

      it "does not cancel a denied event" do
        absence_request.deny!(agent: supervisor)
        expect { absence_request.cancel!(agent: user) }.to raise_error AASM::InvalidTransition
      end
    end
  end

  context "invalid attributes" do
    it "can not assign participation" do
      expect { absence_request.participation = "presenter" }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can not request participation" do
      expect { absence_request.participation }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can assing participation in new" do
      expect { AbsenceRequest.new(participation: "presenter") }.to raise_error ActiveModel::UnknownAttributeError
    end

    it "can not assign purpose" do
      expect { absence_request.purpose = "My grand purpose" }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can not request purpose" do
      expect { absence_request.purpose }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can assing purpose in new" do
      expect { AbsenceRequest.new(purpose: "My grand purpose") }.to raise_error ActiveModel::UnknownAttributeError
    end

    it "can not assign estimates" do
      expect { absence_request.estimates = [Estimate.new] }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can not request estimates" do
      expect { absence_request.estimates }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can assing estimates in new" do
      expect { AbsenceRequest.new(estimates: [Estimate.new]) }.to raise_error ActiveModel::UnknownAttributeError
    end

    it "can not assign event_requests" do
      expect { absence_request.event_requests = [EventRequest.new] }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can not request event_requests" do
      expect { absence_request.event_requests }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can assing event_requests in new" do
      expect { AbsenceRequest.new(event_requests: [EventRequest.new]) }.to raise_error ActiveModel::UnknownAttributeError
    end

    it "can not assign travel_category" do
      expect { absence_request.travel_category = "business" }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can not request travel_category" do
      expect { absence_request.travel_category }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can assing travel_category in new" do
      expect { AbsenceRequest.new(travel_category: "business") }.to raise_error ActiveModel::UnknownAttributeError
    end
  end
end
