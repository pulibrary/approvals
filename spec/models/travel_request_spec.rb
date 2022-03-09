# frozen_string_literal: true
require "rails_helper"

RSpec.describe TravelRequest, type: :model do
  subject(:travel_request) { described_class.new }
  describe "attributes relevant to travel requests" do
    it { is_expected.to respond_to :creator }
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :estimates }
    it { is_expected.to respond_to :event_requests }
    it { is_expected.to respond_to :event_title }
    it { is_expected.to respond_to :notes }
    it { is_expected.to respond_to :participation }
    it { is_expected.to respond_to :purpose }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :status }
    it { is_expected.to respond_to :travel_category }
    it { is_expected.to respond_to :pending? }
    it { is_expected.to respond_to :canceled? }
    it { is_expected.to respond_to :approved? }
    it { is_expected.to respond_to :denied? }
    it { is_expected.to respond_to :changes_requested? }
  end

  describe "#status" do
    it "has a default of pending" do
      expect(travel_request.status).to eq("pending")
    end
  end

  context "A saved absence request" do
    let(:user) { FactoryBot.create :staff_profile, :with_department }
    let(:travel_request) { FactoryBot.create :travel_request, creator: user }
    let(:supervisor) { user.supervisor }
    let(:department_head) { user.department.head }

    describe "#approve!" do
      it "does not approve a pending event unless the approver is a department head" do
        expect do
          travel_request.approve!(agent: supervisor)
        end.to change(StateChange, :count).by(1)

        expect(travel_request.status).to eq("pending")
        expect(travel_request.persisted?).to be_truthy
      end

      it "approves a pending event when the approver is a department head" do
        expect do
          travel_request.approve!(agent: department_head)
        end.to change(StateChange, :count).by(1)
        expect(travel_request.status).to eq("approved")
        expect(travel_request.persisted?).to be_truthy
      end

      it "does not approve a pending event unless the approver is a supervisor" do
        expect { travel_request.approve!(agent: user) }.to raise_error AASM::InvalidTransition
      end

      it "Does not approve a change_request event" do
        travel_request.change_request!(agent: supervisor)
        expect { travel_request.approve!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end

      it "Does not approve a canceled event" do
        travel_request.cancel!(agent: user)
        expect { travel_request.approve!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end

      it "Does not approve a denied event" do
        travel_request.deny!(agent: supervisor)
        expect { travel_request.approve!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end
    end

    describe "#deny!" do
      it "denies a pending event if the agent is their supervisor" do
        expect do
          travel_request.deny!(agent: supervisor)
        end.to change(StateChange, :count).by(1)
        expect(travel_request.status).to eq("denied")
        expect(travel_request.persisted?).to be_truthy
      end

      it "denies a pending event if the agent is their department head" do
        expect do
          travel_request.deny!(agent: department_head)
        end.to change(StateChange, :count).by(1)
        expect(travel_request.status).to eq("denied")
        expect(travel_request.persisted?).to be_truthy
      end

      it "Does not deny an event if the agent is not a supervisor" do
        expect { travel_request.deny!(agent: user) }.to raise_error AASM::InvalidTransition
      end

      it "Does not deny a change_request event" do
        travel_request.change_request!(agent: supervisor)
        expect { travel_request.deny!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end

      it "Does not deny a canceled event" do
        travel_request.cancel!(agent: user)
        expect { travel_request.deny!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end

      it "Does not deny an approved event" do
        travel_request.approve!(agent: user.department.head)
        expect { travel_request.deny!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end
    end

    describe "#change_request!" do
      it "records a change_request event if the requestor is their supervisor" do
        expect do
          travel_request.change_request!(agent: supervisor)
        end.to change(StateChange, :count).by(1)
        expect(travel_request.status).to eq("changes_requested")
        expect(travel_request.persisted?).to be_truthy
      end

      it "records a change_request event if the requestor is their department head" do
        expect do
          travel_request.change_request!(agent: department_head)
        end.to change(StateChange, :count).by(1)
        expect(travel_request.status).to eq("changes_requested")
        expect(travel_request.persisted?).to be_truthy
      end

      it "Does not change_request if the requestor is not their supervisor" do
        expect { travel_request.change_request!(agent: user) }.to raise_error AASM::InvalidTransition
      end

      it "Does not change_request an approved event" do
        travel_request.approve!(agent: user.department.head)
        expect { travel_request.change_request!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end

      it "Does not change_request a canceled event" do
        travel_request.cancel!(agent: user)
        expect { travel_request.change_request!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end

      it "Does not change_request a denied event" do
        travel_request.deny!(agent: supervisor)
        expect { travel_request.change_request!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end
    end

    describe "#cancel!" do
      it "cancels a pending event" do
        expect do
          travel_request.cancel!(agent: user)
        end.to change(StateChange, :count).by(1)
        expect(travel_request.status).to eq("canceled")
        expect(travel_request.persisted?).to be_truthy
      end

      it "cancels an approved event" do
        travel_request.approve!(agent: user.department.head)
        travel_request.cancel!(agent: user)
        expect(travel_request.status).to eq("canceled")
        expect(travel_request.persisted?).to be_truthy
      end

      it "cancels a change_request event" do
        travel_request.change_request!(agent: supervisor)
        travel_request.cancel!(agent: user)
        expect(travel_request.status).to eq("canceled")
        expect(travel_request.persisted?).to be_truthy
      end

      it "does not cancel a denied event" do
        travel_request.deny!(agent: supervisor)
        expect { travel_request.cancel!(agent: user) }.to raise_error AASM::InvalidTransition
      end

      it "does not cancel an pending event if it is not the creator requesting the event" do
        expect { travel_request.cancel!(agent: supervisor) }.to raise_error AASM::InvalidTransition
      end
    end
  end

  context "invalid attributes" do
    it "can not assign absence_type" do
      expect { travel_request.absence_type = "vacation" }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can not request absence_type" do
      expect { travel_request.absence_type }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can assing absence_type in new" do
      expect { described_class.new(absence_type: "vacation") }.to raise_error ActiveModel::UnknownAttributeError
    end

    it "can not assign hours_requested" do
      expect { travel_request.hours_requested = 40 }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can not request hours_requested" do
      expect { travel_request.hours_requested }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can assing hours_requested in new" do
      expect { described_class.new(hours_requested: 40) }.to raise_error ActiveModel::UnknownAttributeError
    end

    it "can not assign end_time" do
      expect { travel_request.end_time = "10:00pm" }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can not request end_time" do
      expect { travel_request.end_time }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can assing end_time in new" do
      expect { described_class.new(end_time: "10:00pm") }.to raise_error ActiveModel::UnknownAttributeError
    end

    it "can not assign start_time" do
      expect { travel_request.start_time = "10:00pm" }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can not request start_time" do
      expect { travel_request.start_time }.to raise_error ActiveModel::UnknownAttributeError
    end
    it "can assing start_time in new" do
      expect { described_class.new(start_time: "10:00pm") }.to raise_error ActiveModel::UnknownAttributeError
    end
  end
end
