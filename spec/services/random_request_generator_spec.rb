# frozen_string_literal: true

require "rails_helper"

RSpec.describe RandomRequestGenerator, type: :model do
  let(:creator) { create(:staff_profile, :with_supervisor, :with_department) }

  before do
    create(:recurring_event)
  end

  context "Pending request" do
    describe ".generate_travel_request" do
      it "generates a travel request" do
        expect do
          described_class.generate_travel_request(creator:)
        end.to change(TravelRequest, :count).by(1)
        request = TravelRequest.last
        expect(request.estimates).not_to be_blank
        expect(request.start_date).not_to be_blank
        expect(request.end_date).not_to be_blank
        expect(request.purpose).not_to be_blank
        expect(request.participation).not_to be_blank
        expect(request.status).to eq("pending")
        expect(request.creator).to eq(creator)
        expect(request.state_changes).to be_blank
        expect(request.notes.count).to eq(1)
        expect(request.event_requests.count).to eq(1)
        expect(request.event_requests.first.location).not_to be_blank
        expect(request.event_requests.first.start_date).not_to be_blank
      end
    end

    describe ".generate_absence_request" do
      it "generates a absence request" do
        expect do
          described_class.generate_absence_request(creator:)
        end.to change(AbsenceRequest, :count).by(1)
        request = AbsenceRequest.last
        expect(request.creator).to eq(creator)
        expect(request.absence_type).not_to be_blank
        expect(request.start_date).not_to be_blank
        expect(request.end_date).not_to be_blank
        expect(request.status).to eq("pending")
        expect(request.state_changes).to be_blank
      end
    end
  end

  context "aproved request" do
    describe ".generate_travel_request" do
      it "generates a travel request" do
        expect do
          described_class.generate_travel_request(creator:, status: "approved")
        end.to change(TravelRequest, :count).by(1)
        request = TravelRequest.last
        expect(request.estimates).not_to be_blank
        expect(request.start_date).not_to be_blank
        expect(request.end_date).not_to be_blank
        expect(request.status).to eq("approved")
        expect(request.creator).to eq(creator)
        expect(request.travel_category).not_to be_blank
        expect(request.state_changes.first.agent).to eq(creator.supervisor)
        expect(request.state_changes.count).to eq(2)
        expect(request.state_changes.last.agent).to eq(creator.department.head)
        expect(request.notes.count).to eq(1)
      end
    end

    describe ".generate_absence_request" do
      it "generates a absence request" do
        expect do
          described_class.generate_absence_request(creator:, status: "approved")
        end.to change(AbsenceRequest, :count).by(1)
        request = AbsenceRequest.last
        expect(request.creator).to eq(creator)
        expect(request.absence_type).not_to be_blank
        expect(request.start_date).not_to be_blank
        expect(request.end_date).not_to be_blank
        expect(request.status).to eq("approved")
        expect(request.state_changes.first.agent).to eq(creator.supervisor)
        expect(request.state_changes.count).to eq(1)
        expect(request.notes.count).to eq(1)
      end
    end
  end

  context "denied request" do
    describe ".generate_travel_request" do
      it "generates a travel request" do
        expect do
          described_class.generate_travel_request(creator:, status: "denied")
        end.to change(TravelRequest, :count).by(1)
        request = TravelRequest.last
        expect(request.estimates).not_to be_blank
        expect(request.start_date).not_to be_blank
        expect(request.end_date).not_to be_blank
        expect(request.status).to eq("denied")
        expect(request.creator).to eq(creator)
        expect(request.state_changes.first.agent).to eq(creator.supervisor)
        expect(request.state_changes.first.action).to eq("denied")
        expect(request.state_changes.count).to eq(1)
        expect(request.notes.count).to eq(2)
      end
    end

    describe ".generate_absence_request" do
      it "generates a absence request" do
        expect do
          described_class.generate_absence_request(creator:, status: "denied")
        end.to change(AbsenceRequest, :count).by(1)
        request = AbsenceRequest.last
        expect(request.creator).to eq(creator)
        expect(request.absence_type).not_to be_blank
        expect(request.start_date).not_to be_blank
        expect(request.end_date).not_to be_blank
        expect(request.status).to eq("denied")
        expect(request.state_changes.first.agent).to eq(creator.supervisor)
        expect(request.state_changes.first.action).to eq("denied")
        expect(request.state_changes.count).to eq(1)
        expect(request.notes.count).to eq(2)
      end
    end
  end
end
