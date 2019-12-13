# frozen_string_literal: true
require "rails_helper"

RSpec.describe RecordingRequestList, type: :model do
  let(:user) { FactoryBot.create :user }
  let(:staff_profile) { FactoryBot.create :staff_profile, :with_department, user: user }

  let(:other_absence) { FactoryBot.create(:absence_request) }
  let(:other_travel) { FactoryBot.create(:travel_request) }
  let(:my_absence) { FactoryBot.create(:absence_request, creator: staff_profile, start_date: Time.zone.tomorrow) }
  let(:my_travel) { FactoryBot.create(:travel_request, creator: staff_profile) }

  describe "GET #list_requests" do
    before do
      # create all the requests
      other_absence
      other_travel
      my_absence
      my_travel
    end
    it "returns a success response" do
      list = RecordingRequestList.list_requests(request_filters: nil, search_query: nil, order: nil)
      expect(list.first).to be_a AbsenceRequest
      expect(list.last).to be_a AbsenceRequest
      expect(list.map(&:id)).to contain_exactly(*[other_absence, my_absence].map(&:id))
    end

    it "accepts limit by status" do
      approved_absence = FactoryBot.create(:absence_request, action: :approve, creator: staff_profile)
      list = RecordingRequestList.list_requests(request_filters: { status: "approved" }, search_query: nil, order: nil)
      expect(list.map(&:id)).to contain_exactly(approved_absence.id)
    end

    it "accepts limit by request type absence" do
      list = RecordingRequestList.list_requests(request_filters: { "request_type" => "absence" }, search_query: nil, order: nil)
      expect(list.map(&:id)).to contain_exactly(*[other_absence, my_absence].map(&:id))
    end

    it "accepts limit by request type sick" do
      my_sick_absence = FactoryBot.create(:absence_request, creator: staff_profile, absence_type: "sick")
      list = RecordingRequestList.list_requests(request_filters: { "request_type" => "sick" }, search_query: nil, order: nil)
      expect(list.map(&:id)).to contain_exactly(my_sick_absence.id)
    end

    it "accepts limit by request type travel" do
      list = RecordingRequestList.list_requests(request_filters: { "request_type" => "travel" }, search_query: nil, order: nil)
      expect(list.map(&:id)).to contain_exactly(*[other_travel, my_travel].map(&:id))
    end

    it "accepts limit by request type business" do
      my_business_travel = FactoryBot.create(:travel_request, creator: staff_profile, travel_category: "business")
      list = RecordingRequestList.list_requests(request_filters: { "request_type" => "business" }, search_query: nil, order: nil)
      expect(list.map(&:id)).to contain_exactly(my_business_travel.id)
    end

    it "accepts limit by status and request type" do
      my_business_travel = FactoryBot.create(:travel_request, creator: staff_profile, action: "approve", travel_category: "business")
      FactoryBot.create(:travel_request, creator: staff_profile, action: "approve", travel_category: "discretionary")
      list = RecordingRequestList.list_requests(request_filters: { "request_type" => "business", "status" => "approved" }, search_query: nil, order: nil)
      expect(list.map(&:id)).to contain_exactly(my_business_travel.id)
    end

    it "accepts limit by department" do
      list = RecordingRequestList.list_requests(request_filters: { "department" => staff_profile.department.number }, search_query: nil, order: nil)
      expect(list.map(&:id)).to contain_exactly(*[my_absence].map(&:id))
    end
  end

  describe "GET #my_requests with sort params" do
    let(:yesterday) { Time.zone.yesterday }
    let(:today) { Time.zone.today }
    let(:tomorrow) { Time.zone.tomorrow }
    # r1: created yesterday, modified tomorrow, start date today
    let(:r1) do
      Timecop.freeze(yesterday) do
        FactoryBot.create(:absence_request, creator: staff_profile, start_date: today)
      end
    end
    # r2: created today, modified yesterday, start date tomorrow
    let(:r2) do
      Timecop.freeze(today) do
        FactoryBot.create(:absence_request, creator: staff_profile, start_date: tomorrow)
      end
    end
    # r3: created tomorrow, modified today, start date yesterday
    let(:r3) do
      Timecop.freeze(tomorrow) do
        FactoryBot.create(:absence_request, creator: staff_profile, start_date: yesterday)
      end
    end

    before do
      yesterday
      today
      tomorrow
      Timecop.freeze(yesterday) do
        r2.approve!(agent: staff_profile.department.head)
      end
      r3.approve!(agent: staff_profile.department.head)
      Timecop.freeze(tomorrow) do
        r1.approve!(agent: staff_profile.department.head)
      end
    end

    it "by default sorts by updated date descending" do
      list = RecordingRequestList.list_requests(request_filters: nil, search_query: nil, order: nil)
      expect(list.map(&:id)).to eq [r1, r3, r2].map(&:id)
    end

    context "sort by start date" do
      it "by default sorts by start date descending" do
        list = RecordingRequestList.list_requests(request_filters: nil, search_query: nil, order: "start_date_desc")
        expect(list.map(&:id)).to eq [r2, r1, r3].map(&:id)
      end

      it "sorts ascending" do
        list = RecordingRequestList.list_requests(request_filters: nil, search_query: nil, order: "start_date_asc")
        expect(list.map(&:id)).to eq [r3, r1, r2].map(&:id)
      end
    end

    context "sort by date created" do
      it "sorts ascending" do
        list = RecordingRequestList.list_requests(request_filters: nil, search_query: nil, order: "created_at_asc")
        expect(list.map(&:id)).to eq [r1, r2, r3].map(&:id)
      end

      it "sorts descending" do
        list = RecordingRequestList.list_requests(request_filters: nil, search_query: nil, order: "created_at_desc")
        expect(list.map(&:id)).to eq [r3, r2, r1].map(&:id)
      end
    end

    context "sort by date modified" do
      it "sorts ascending" do
        list = RecordingRequestList.list_requests(request_filters: nil, search_query: nil, order: "updated_at_asc")
        expect(list.map(&:id)).to eq [r2, r3, r1].map(&:id)
      end

      it "sorts descending" do
        list = RecordingRequestList.list_requests(request_filters: nil, search_query: nil, order: "updated_at_desc")
        expect(list.map(&:id)).to eq [r1, r3, r2].map(&:id)
      end
    end
  end

  describe "GET #my_requests with searching" do
    it "retrieves a result" do
      absence_request = FactoryBot.create(:absence_request, creator: staff_profile, action: :approve)
      absence_request2 = FactoryBot.create(:absence_request, creator: staff_profile, action: :deny)
      travel_request = FactoryBot.create(:travel_request, creator: staff_profile)
      FactoryBot.create(:note, content: "elephants love balloons", request: absence_request)
      FactoryBot.create(:note, content: "elephants love balloons", request: absence_request2)
      FactoryBot.create(:note, content: "flamingoes are pink because of shrimp", request: travel_request)

      list = RecordingRequestList.list_requests(request_filters: { "status" => "approved" }, search_query: "balloons", order: nil)
      expect(list.count).to eq 1
    end
  end
end
