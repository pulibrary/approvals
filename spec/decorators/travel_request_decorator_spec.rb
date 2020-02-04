# frozen_string_literal: true
require "rails_helper"

RSpec.describe TravelRequestDecorator, type: :model do
  subject(:travel_request_decorator) { described_class.new(travel_request) }
  let(:travel_request) { FactoryBot.create(:travel_request) }

  describe "attributes relevant to TravelRequest" do
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :id }
    it { is_expected.to respond_to :request_type }
    it { is_expected.to respond_to :state_changes }
    it { is_expected.to respond_to :status }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :to_model }
    it { is_expected.to respond_to :travel_category }
    it { is_expected.to respond_to :creator }
    it { is_expected.to respond_to :notes }
    it { is_expected.to respond_to :event_requests }
    it { is_expected.to respond_to :estimates }
    it { is_expected.to respond_to :event_title }
  end

  describe "#travel_category_icon" do
    context "when travel_category is None" do
      it "returns the correct lux icon" do
        expect(travel_request_decorator.travel_category_icon).to eq "lux-icon-globe"
      end
    end
    context "when travel_category is Business" do
      let(:travel_request) { FactoryBot.create(:travel_request, travel_category: :business) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.travel_category_icon).to eq "lux-icon-globe"
      end
    end
    context "when travel_category is professional development" do
      let(:travel_request) { FactoryBot.create(:travel_request, travel_category: :professional_development) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.travel_category_icon).to eq "lux-icon-globe"
      end
    end
    context "when travel_category is discretionary" do
      let(:travel_request) { FactoryBot.create(:travel_request, travel_category: :discretionary) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.travel_category_icon).to eq "lux-icon-globe"
      end
    end
  end

  describe "#formatted_start_date" do
    let(:travel_request) { FactoryBot.create(:travel_request, start_date: Time.zone.parse("2019-07-04 12:12")) }
    it "returns a formated start date" do
      expect(travel_request_decorator.formatted_start_date).to eq "07/04/2019"
    end
  end

  describe "#formatted_full_start_date" do
    let(:travel_request) { FactoryBot.create(:travel_request, start_date: Time.zone.parse("2019-07-04 12:12")) }
    it "returns a formated start date" do
      expect(travel_request_decorator.formatted_full_start_date).to eq "July 4, 2019"
    end
  end

  describe "#formatted_end_date" do
    let(:travel_request) { FactoryBot.create(:travel_request, end_date: Time.zone.parse("2019-07-04 12:12")) }
    it "returns a formated end date" do
      expect(travel_request_decorator.formatted_end_date).to eq "07/04/2019"
    end
  end

  describe "#formatted_full_end_date" do
    let(:travel_request) { FactoryBot.create(:travel_request, end_date: Time.zone.parse("2019-07-04 12:12")) }
    it "returns a formated end date" do
      expect(travel_request_decorator.formatted_full_end_date).to eq "July 4, 2019"
    end
  end

  describe "#status_icon" do
    let(:travel_request) { FactoryBot.create(:travel_request) }
    it "returns the correct lux icon" do
      expect(travel_request_decorator.status_icon).to eq "clock"
    end

    context "when travel has been approved" do
      let(:travel_request) { FactoryBot.create(:travel_request, action: :approve) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.status_icon).to eq "approved"
      end
    end

    context "when travel has been denied" do
      let(:travel_request) { FactoryBot.create(:travel_request, action: :deny) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.status_icon).to eq "denied"
      end
    end

    context "when travel has been changes_requested" do
      let(:travel_request) { FactoryBot.create(:travel_request, action: :change_request) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.status_icon).to eq "refresh"
      end
    end

    context "when travel has been canceled" do
      let(:travel_request) { FactoryBot.create(:travel_request, action: :cancel) }
      it "returns the correct lux icon" do
        expect(travel_request_decorator.status_icon).to eq "alert"
      end
    end
  end

  describe "#latest_status" do
    let(:travel_request) { FactoryBot.create(:travel_request) }
    let(:today) { Time.zone.now }
    it "returns the status and the createddate" do
      expect(travel_request_decorator.latest_status).to eq "Pending"
      expect(travel_request_decorator.latest_status_date).to eq "Updated on #{today.strftime('%m/%d/%Y')}"
    end

    context "it has been approved and then canceled" do
      let(:travel_request) { FactoryBot.create(:travel_request, action: :approve) }
      it "returns the last created status and date" do
        travel_request.cancel!(agent: travel_request.creator)
        expect(travel_request_decorator.latest_status).to eq "Canceled"
        expect(travel_request_decorator.latest_status_date).to eq "Updated on #{today.strftime('%m/%d/%Y')}"
      end
    end

    context "approved but waiting on further review" do
      let(:creator) { FactoryBot.create :staff_profile, :with_supervisor }
      let(:travel_request) { FactoryBot.create(:travel_request, creator: creator) }
      it "returns pending futher review" do
        travel_request.approve!(agent: travel_request.creator.supervisor)
        expect(travel_request_decorator.latest_status).to eq "Pending further review"
        expect(travel_request_decorator.latest_status_date).to eq "Updated on #{today.strftime('%m/%d/%Y')}"
      end
    end
  end

  describe "#estimates_json" do
    it "returns json data" do
      expect(travel_request_decorator.estimates_json).to eq '[{"cost_type":"","note":"","recurrence":"","amount":"Total:","total":"0.00"}]'
    end

    context "with estimate" do
      let(:travel_request) { FactoryBot.create(:travel_request, :with_note_and_estimate) }
      it "returns json data" do
        expect(travel_request_decorator.estimates_json).to eq(
          '[{"cost_type":"Lodging (per night)","note":"","recurrence":3,"amount":"50.00","total":"150.00"},' \
          '{"cost_type":"","note":"","recurrence":"","amount":"Total:","total":"150.00"}]'
        )
      end
    end
  end

  describe "#notes_and_changes" do
    let(:department_head) { FactoryBot.create(:staff_profile, :as_department_head, given_name: "Department", surname: "Head") }
    let(:admin_assistant) { FactoryBot.create(:staff_profile, given_name: "Admin", surname: "Assistant", department: department_head.department) }
    let(:supervisor) { FactoryBot.create(:staff_profile, given_name: "Sally", surname: "Supervisor", department: department_head.department, supervisor: department_head) }
    let(:staff) { FactoryBot.create(:staff_profile, given_name: "Staff", surname: "Person", department: department_head.department, supervisor: supervisor) }
    let(:travel_request) do
      request = FactoryBot.create(:travel_request, creator: staff)
      request.notes << FactoryBot.build(:note, content: "Please approve", creator: staff)
      request.approve(agent: supervisor)
      request.notes << FactoryBot.build(:note, content: "looks good", creator: supervisor)
      department_head.current_delegate = admin_assistant
      request.approve(agent: department_head)
      request
    end

    it "returns the combined data" do
      expect(travel_request_decorator.notes_and_changes).to eq([
                                                                 { title: "Created by Staff Person on #{Time.zone.now.strftime('%m/%d/%Y')}", content: nil,
                                                                   icon: "add" },
                                                                 { title: "Staff Person on #{Time.zone.now.strftime('%m/%d/%Y')}", content: "Please approve",
                                                                   icon: "note" },
                                                                 { title: "Approved by Sally Supervisor on #{Time.zone.now.strftime('%m/%d/%Y')}", content: nil,
                                                                   icon: "approved" },
                                                                 { title: "Sally Supervisor on #{Time.zone.now.strftime('%m/%d/%Y')}", content: "looks good",
                                                                   icon: "note" },
                                                                 { title: "Approved by Admin Assistant on behalf of Department Head on #{Time.zone.now.strftime('%m/%d/%Y')}", content: nil,
                                                                   icon: "approved" }
                                                               ])
    end

    context "when changes requested" do
      let(:travel_request) do
        request = FactoryBot.create(:travel_request, creator: staff)
        request.notes << FactoryBot.build(:note, content: "Please approve", creator: staff)
        request.approve(agent: supervisor)
        request.notes << FactoryBot.build(:note, content: "looks good", creator: supervisor)
        request.change_request(agent: department_head)
        request.notes << FactoryBot.build(:note, content: "change stuff", creator: department_head)
        request.fix_requested_changes(agent: staff)
        request
      end

      it "returns the changes requested icon" do
        expect(travel_request_decorator.notes_and_changes).to eq([
                                                                   { title: "Created by Staff Person on #{Time.zone.now.strftime('%m/%d/%Y')}", content: nil,
                                                                     icon: "add" },
                                                                   { title: "Staff Person on #{Time.zone.now.strftime('%m/%d/%Y')}", content: "Please approve",
                                                                     icon: "note" },
                                                                   { title: "Approved by Sally Supervisor on #{Time.zone.now.strftime('%m/%d/%Y')}", content: nil,
                                                                     icon: "approved" },
                                                                   { title: "Sally Supervisor on #{Time.zone.now.strftime('%m/%d/%Y')}", content: "looks good",
                                                                     icon: "note" },
                                                                   { title: "Changes Requested by Department Head on #{Time.zone.now.strftime('%m/%d/%Y')}", content: nil,
                                                                     icon: "refresh" },
                                                                   { title: "Department Head on #{Time.zone.now.strftime('%m/%d/%Y')}", content: "change stuff",
                                                                     icon: "note" },
                                                                   { title: "Updated by Staff Person on #{Time.zone.now.strftime('%m/%d/%Y')}", content: nil,
                                                                     icon: "clock" }
                                                                 ])
      end
    end
  end

  describe "#event_attendees" do
    let(:staff_profile) { FactoryBot.create(:staff_profile, :with_department, given_name: "Jane") }
    let(:staff_profile2) { FactoryBot.create(:staff_profile, :with_department, given_name: "Joe") }
    let(:travel_request) do
      FactoryBot.create(:travel_request, creator: staff_profile)
    end
    let(:travel_request2) do
      FactoryBot.create(:travel_request, event_requests: travel_request.event_requests, creator: staff_profile2)
    end

    it "returns others who want to attend the same event" do
      travel_request2
      expect(travel_request_decorator.event_attendees).to eq([staff_profile2])
    end

    it "returns no one wants to attend the same event" do
      expect(travel_request_decorator.event_attendees).to eq(["No others attending"])
    end
  end

  describe "#absent_staff" do
    let(:staff_profile) { FactoryBot.create(:staff_profile, :with_department, given_name: "Jane") }
    let(:staff_profile2) { FactoryBot.create(:staff_profile, supervisor: staff_profile.supervisor, department: staff_profile.department, given_name: "Joe") }
    let(:travel_request) do
      FactoryBot.create(:travel_request, creator: staff_profile)
    end
    let(:absence_request) do
      FactoryBot.create(:absence_request, creator: staff_profile2)
    end

    it "returns others who will be absent during the event time frame" do
      absence_request
      expect(travel_request_decorator.absent_staff).to eq([staff_profile2])
    end

    it "returns that no one wil be absent during the event" do
      expect(travel_request_decorator.absent_staff).to eq(["No team members absent"])
    end
  end
end
