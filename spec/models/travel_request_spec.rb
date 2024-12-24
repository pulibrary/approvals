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

  context "A saved travel request" do
    let(:user) { create(:staff_profile, :with_department) }
    let(:supervisor) { user.supervisor }
    let(:department_head) { user.department.head }

    context "with one estimate" do
      let(:travel_request) { create(:travel_request, :with_note_and_estimate, creator: user) }

      it "gives a total estimate" do
        expect(travel_request.estimated_total).to eq(150)
      end
    end

    context "with multiple estimates" do
      let(:travel_request) do
        create(
          :travel_request,
          :with_note_and_estimate,
          creator: user,
          estimates: [build(:estimate), build(:estimate)]
        )
      end

      it "gives a total estimate" do
        expect(travel_request.estimated_total).to eq(300)
      end
    end
  end

  context "A saved absence request" do
    let(:user) { create(:staff_profile, :with_department) }
    let(:travel_request) { create(:travel_request, creator: user) }
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

    describe "#update_recurring_events!" do
      let(:recurring_event) { create(:recurring_event, name: "Max's test event") }

      it "can update the associated recurring event" do
        expect do
          travel_request.update_recurring_events!(target_recurring_event: recurring_event)
        end.to change(travel_request.reload,
                      :event_title).from(/Event \d* \d*, Location/).to(/Max's test event \d*, Location/)
      end

      it "does not update the nested event_requests" do
        expect do
          travel_request.update_recurring_events!(target_recurring_event: recurring_event)
        end.not_to change { travel_request.reload.event_requests.first }
      end

      context "with two travel requests" do
        let(:target_recurring_event) { build(:recurring_event, name: "Target event name") }
        let(:event_with_target_name) { build(:event_request, recurring_event: target_recurring_event) }
        let(:travel_request_unchanged) { create(:travel_request, event_requests: [event_with_target_name]) }

        let(:unwanted_recurring_event) { build(:recurring_event, name: "Unwanted event name") }
        let(:event_with_unwanted_name) { build(:event_request, recurring_event: unwanted_recurring_event) }
        let(:travel_request_unwanted_name) do
 create(:travel_request, event_requests: [event_with_unwanted_name])
        end

        before do
          travel_request_unchanged
          travel_request_unwanted_name
        end

        it "deletes an orphaned recurring event" do
          expect(target_recurring_event).to be
          expect(unwanted_recurring_event).to be

          travel_request_unwanted_name.update_recurring_events!(target_recurring_event:)

          expect(target_recurring_event.reload).to be
          expect { unwanted_recurring_event.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "does not change the properties of the unchanged travel request" do
          # set and check the original properties of the travel request that should not change
          tru = travel_request_unchanged
          tru_recurring_event_before = tru.recurring_events.first
          expect(tru_recurring_event_before).to eq(target_recurring_event)
          tru_event_request_before = tru.event_requests.first
          expect(tru_event_request_before).to eq(event_with_target_name)
          # set and check the original properties of the travel request that *should* change
          tr_uw = travel_request_unwanted_name
          tr_uw_recurring_event_before = tr_uw.recurring_events.first
          expect(tr_uw_recurring_event_before).to eq(unwanted_recurring_event)
          tr_uw_event_request_before = tr_uw.event_requests.first
          expect(tr_uw_event_request_before).to eq(event_with_unwanted_name)

          # run the update
          tr_uw.update_recurring_events!(target_recurring_event:)

          # ensure the travel request that should not change has not changed
          expect(travel_request_unchanged.reload.recurring_events.first).to eq(tru_recurring_event_before)
          expect(travel_request_unchanged.reload.event_requests.first).to eq(tru_event_request_before)

          # ensure the travel request that should change has changed
          expect(travel_request_unwanted_name.reload.recurring_events.first).to eq(target_recurring_event)
          expect(travel_request_unwanted_name.reload.event_requests.first).to eq(tr_uw_event_request_before)
          expect(travel_request_unwanted_name.reload.event_title).to include("Target event name")
        end

        context "with three travel requests" do
          let(:second_event_with_unwanted_name) do
 build(:event_request, recurring_event: unwanted_recurring_event)
          end
          let(:second_travel_request_with_unwanted_name) do
 create(:travel_request, event_requests: [second_event_with_unwanted_name])
          end

          before do
            second_travel_request_with_unwanted_name
          end

          it "does not delete a recurring event that is not orphaned" do
            expect(second_travel_request_with_unwanted_name.recurring_events.first).to eq(unwanted_recurring_event)
            expect(target_recurring_event).to be
            expect(unwanted_recurring_event).to be

            travel_request_unwanted_name.update_recurring_events!(target_recurring_event:)

            expect(target_recurring_event.reload).to be
            expect(unwanted_recurring_event.reload).to be
            expect { unwanted_recurring_event.reload }.not_to raise_error
            expect(second_travel_request_with_unwanted_name.reload.recurring_events.first).to eq(unwanted_recurring_event)
          end
        end
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
