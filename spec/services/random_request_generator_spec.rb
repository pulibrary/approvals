require "rails_helper"

RSpec.describe RandomRequestGenerator, type: :model do
  let(:creator) { FactoryBot.create :staff_profile, :with_supervisor, :with_department }
  before do
    FactoryBot.create :recurring_event
  end

  context "Pending request" do
    describe ".generate_travel_request" do
      it "generates a travel request" do
        expect do
          RandomRequestGenerator.generate_travel_request(creator: creator)
        end.to change(TravelRequest, :count).by(1)
        request = TravelRequest.last
        expect(request.estimates).not_to be_blank
        expect(request.start_date).not_to be_blank
        expect(request.end_date).not_to be_blank
        expect(request.status).to eq("pending")
        expect(request.creator).to eq(creator)
        expect(request.state_changes).to be_blank
        expect(request.notes.count).to eq(1)
      end
    end

    describe ".generate_absence_request" do
      it "generates a absence request" do
        expect do
          RandomRequestGenerator.generate_absence_request(creator: creator)
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
          RandomRequestGenerator.generate_travel_request(creator: creator, status: "approved")
        end.to change(TravelRequest, :count).by(1)
        request = TravelRequest.last
        expect(request.estimates).not_to be_blank
        expect(request.start_date).not_to be_blank
        expect(request.end_date).not_to be_blank
        expect(request.status).to eq("approved")
        expect(request.creator).to eq(creator)
        expect(request.travel_category).not_to be_blank
        expect(request.state_changes.first.approver).to eq(creator.supervisor)
        expect(request.state_changes.count).to eq(2)
        expect(request.state_changes.last.approver).to eq(creator.department.head)
        expect(request.notes.count).to eq(1)
      end
    end

    describe ".generate_absence_request" do
      it "generates a absence request" do
        expect do
          RandomRequestGenerator.generate_absence_request(creator: creator, status: "approved")
        end.to change(AbsenceRequest, :count).by(1)
        request = AbsenceRequest.last
        expect(request.creator).to eq(creator)
        expect(request.absence_type).not_to be_blank
        expect(request.start_date).not_to be_blank
        expect(request.end_date).not_to be_blank
        expect(request.status).to eq("approved")
        expect(request.state_changes.first.approver).to eq(creator.supervisor)
        expect(request.state_changes.count).to eq(1)
        expect(request.notes.count).to eq(1)
      end
    end
  end

  context "denied request" do
    describe ".generate_travel_request" do
      it "generates a travel request" do
        expect do
          RandomRequestGenerator.generate_travel_request(creator: creator, status: "denied")
        end.to change(TravelRequest, :count).by(1)
        request = TravelRequest.last
        expect(request.estimates).not_to be_blank
        expect(request.start_date).not_to be_blank
        expect(request.end_date).not_to be_blank
        expect(request.status).to eq("denied")
        expect(request.creator).to eq(creator)
        expect(request.state_changes.first.approver).to eq(creator.supervisor)
        expect(request.state_changes.first.action).to eq("denied")
        expect(request.state_changes.count).to eq(1)
        expect(request.notes.count).to eq(2)
      end
    end

    describe ".generate_absence_request" do
      it "generates a absence request" do
        expect do
          RandomRequestGenerator.generate_absence_request(creator: creator, status: "denied")
        end.to change(AbsenceRequest, :count).by(1)
        request = AbsenceRequest.last
        expect(request.creator).to eq(creator)
        expect(request.absence_type).not_to be_blank
        expect(request.start_date).not_to be_blank
        expect(request.end_date).not_to be_blank
        expect(request.status).to eq("denied")
        expect(request.state_changes.first.approver).to eq(creator.supervisor)
        expect(request.state_changes.first.action).to eq("denied")
        expect(request.state_changes.count).to eq(1)
        expect(request.notes.count).to eq(2)
      end
    end
  end
end
