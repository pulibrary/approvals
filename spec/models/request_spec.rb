# frozen_string_literal: true

require "rails_helper"

RSpec.describe Request, type: :model do
  describe "attributes relevant to all requests" do
    subject { described_class.new }

    it { is_expected.to respond_to :creator }
    it { is_expected.to respond_to :status }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :notes }
    it { is_expected.to respond_to :request_type }
  end

  describe "#id" do
    it "id is greater than ten thousand" do
      expect(create(:absence_request).id).to be >= 10_000
    end
  end

  # Most attributes are tested on the controller, but status will never be set
  # by form (see https://github.com/pulibrary/approvals/issues/112)
  # so test here on the model. Maybe replace with other controller tests
  # when we work that ticket.
  describe "status enum" do
    let(:staff_profile) { create(:staff_profile, :with_department) }
    let(:travel_request) { build(:travel_request, creator: staff_profile) }
    let(:absence_request) { build(:absence_request, creator: staff_profile) }

    it "set expected values" do
      expect(travel_request.pending?).to be true
      travel_request.change_request(agent: staff_profile.department.head)
      expect(travel_request.changes_requested?).to be true
      travel_request.fix_requested_changes(agent: absence_request.creator)
      expect(travel_request.pending?).to be true
      travel_request.approve(agent: staff_profile.department.head)
      expect(travel_request.approved?).to be true
      travel_request.cancel(agent: absence_request.creator)
      expect(travel_request.canceled?).to be true
    end

    it "can be denied" do
      travel_request.deny(agent: staff_profile.department.head)
      expect(travel_request.denied?).to be true
    end

    it "transitions through stages for absence" do
      absence_request.approve(agent: staff_profile.department.head)
      expect(absence_request.approved?).to be true
      absence_request.record(agent: staff_profile.department.head)
      expect(absence_request.recorded?).to be true
    end

    it "errors for invalid values" do
      expect { travel_request.status = "invalid_status" }.to raise_error AASM::NoDirectAssignmentError
    end
  end

  describe "#destory" do
    it "destroys dependant notes and estimates" do
      travel_request = create(:travel_request, action: :approve)
      create(:note, content: "Flamingoes are pink, because they eat lots of shrimp.",
                    request: travel_request)
      create(:estimate, request: travel_request)
      expect { travel_request.destroy }.to(
        change(Note, :count).by(-1).and(
          change(Estimate, :count).by(-1)
        ).and(
          change(EventRequest, :count).by(-1)
        ).and(
          change(StateChange, :count).by(-1)
        )
      )
    end
  end

  describe "#where_contains_text" do
    let(:absence_request) { create(:absence_request, action: :approve) }
    let(:absence_request2) { create(:absence_request, action: :deny) }
    let(:travel_request) { create(:travel_request, action: :approve) }
    let(:travel_request2) { create(:travel_request) }

    before do
      create(:note, content: "elephants love balloons", request: absence_request)
      create(:note, content: "Elephants love balloons", request: absence_request2)
      create(:note, content: "Flamingoes are pink, because they eat lots of shrimp.",
                    request: travel_request)
      create(:note, content: "Bears can't fly", request: travel_request)
      travel_request2 # no note just create it
    end

    it "finds all when search_query is blank" do
      expect(described_class.where_contains_text(search_query: nil).map(&:id)).to contain_exactly(absence_request.id,
                                                                                                  absence_request2.id, travel_request.id, travel_request2.id)
    end

    it "finds an ending word" do
      expect(described_class.where_contains_text(search_query: "balloons").map(&:id)).to contain_exactly(
        absence_request.id, absence_request2.id
      )
    end

    it "finds a starting word" do
      expect(described_class.where_contains_text(search_query: "Flamingo").map(&:id)).to contain_exactly(travel_request.id)
    end

    it "finds a middle word" do
      expect(described_class.where_contains_text(search_query: "love").map(&:id)).to contain_exactly(
        absence_request.id, absence_request2.id
      )
    end

    it "finds a case insensitive word" do
      expect(described_class.where_contains_text(search_query: "elephant").map(&:id)).to contain_exactly(
        absence_request.id, absence_request2.id
      )
      expect(described_class.where_contains_text(search_query: "Elephant").map(&:id)).to contain_exactly(
        absence_request.id, absence_request2.id
      )
    end

    it "finds a phrase with punctuation in a second note" do
      expect(described_class.where_contains_text(search_query: "Bears can't").map(&:id)).to contain_exactly(travel_request.id)
    end

    it "finds a travel event title" do
      expect(described_class.where_contains_text(search_query: "#{Time.zone.today.year}, Location").map(&:id)).to contain_exactly(
        travel_request.id, travel_request2.id
      )
    end

    it "finds a request by id" do
      expect(described_class.where_contains_text(search_query: travel_request.id.to_s).map(&:id)).to contain_exactly(travel_request.id)
    end

    it "finds none with a non existant phrase" do
      expect(described_class.where_contains_text(search_query: "Cats hate water").map(&:id)).to be_empty
    end
  end
end
