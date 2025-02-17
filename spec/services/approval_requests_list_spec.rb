# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApprovalRequestList, type: :model do
  let(:user) { create(:user, uid: "abc123") }
  let(:staff_profile) { create(:staff_profile, :with_department, user:) }
  let(:user_two) { create(:user, uid: "abc12345") }
  let(:staff_profile_two) { create(:staff_profile, :with_department, user: user_two) }
  let(:other_absence) { create(:absence_request) }
  let(:other_travel) { create(:travel_request) }
  let(:my_absence) { create(:absence_request, creator: staff_profile, start_date: Time.zone.tomorrow) }
  let(:my_travel) { create(:travel_request, creator: staff_profile) }

  describe "#list_requests" do
    before do
      staff_profile.supervisor.save
      staff_profile_two.supervisor.save
      # create all the requests
      other_absence
      other_travel
      my_absence
      my_travel
    end

    it "does not list requests when the approver is not a supervisor of the request creator" do
      supervisor = create(:staff_profile, :with_department)
      supervisor.supervisor = nil
      supervisor.save
      department_one = create(:department, :with_head, admin_assistants: [staff_profile_two])
      staff_profile = create(:staff_profile, supervisor: supervisor, department: department_one)
      other_travel_two = create(:travel_request, creator: staff_profile)
      expect { other_travel_two.approve(agent: department_one.head) }.not_to raise_error
      # expect(other_travel_two).not_to be_approved # See issue: https://github.com/pulibrary/approvals/issues/808
    end

    it "returns a success response" do
      list = described_class.list_requests(approver: staff_profile.supervisor, request_filters: nil, search_query: nil,
                                           order: nil)
      expect(list.count).to be(2)
      expect(list.first).to be_a TravelRequest
      expect(list.last).to be_a AbsenceRequest
      expect(list.map(&:id)).to contain_exactly(*[my_absence, my_travel].map(&:id))
    end

    it "does not show canceled requests" do
      my_travel.cancel!(agent: staff_profile)
      list = described_class.list_requests(approver: staff_profile.supervisor, request_filters: nil, search_query: nil,
                                           order: nil)
      expect(list.count).to be(1)
      expect(list.map(&:id)).to contain_exactly(my_absence.id)
    end

    it "does not show denied requests" do
      my_travel.deny!(agent: staff_profile.supervisor)
      list = described_class.list_requests(approver: staff_profile.supervisor, request_filters: nil, search_query: nil,
                                           order: nil)
      expect(list.count).to be(1)
      expect(list.map(&:id)).to contain_exactly(my_absence.id)
    end

    it "does not show approved requests" do
      my_travel.approve!(agent: staff_profile.department.head)
      list = described_class.list_requests(approver: staff_profile.supervisor, request_filters: nil, search_query: nil,
                                           order: nil)
      expect(list.count).to be(1)
      expect(list.map(&:id)).to contain_exactly(my_absence.id)
    end

    it "does not show request already approved by the approver" do
      my_travel.approve!(agent: staff_profile.supervisor)
      list = described_class.list_requests(approver: staff_profile.supervisor, request_filters: nil, search_query: nil,
                                           order: nil)
      expect(list.count).to be(1)
      expect(list.map(&:id)).to contain_exactly(my_absence.id)
    end

    it "does not show request that are not ready for the approver to approve" do
      list = described_class.list_requests(approver: staff_profile.supervisor.supervisor, request_filters: nil,
                                           search_query: nil, order: nil)
      expect(list.count).to be(0)
    end

    it "does show request that are ready for the approver to approve" do
      my_travel.approve(agent: staff_profile.supervisor)
      list = described_class.list_requests(approver: staff_profile.supervisor.supervisor, request_filters: nil,
                                           search_query: nil, order: nil)
      expect(list.count).to be(1)
      expect(list.map(&:id)).to contain_exactly(my_travel.id)
    end

    it "accepts limit by status" do
      requested_changes_travel = create(:travel_request, action: :change_request, creator: staff_profile)
      list = described_class.list_requests(approver: staff_profile.supervisor,
                                           request_filters: { status: "changes_requested" }, search_query: nil, order: nil)
      expect(list.map(&:id)).to contain_exactly(requested_changes_travel.id)
    end

    it "accepts limit by request type absence" do
      list = described_class.list_requests(approver: staff_profile.supervisor,
                                           request_filters: { "request_type" => "absence" }, search_query: nil, order: nil)
      expect(list.map(&:id)).to contain_exactly(my_absence.id)
    end

    it "accepts limit by request type sick" do
      my_sick_absence = create(:absence_request, creator: staff_profile, absence_type: "sick")
      list = described_class.list_requests(approver: staff_profile.supervisor,
                                           request_filters: { "request_type" => "sick" }, search_query: nil, order: nil)
      expect(list.map(&:id)).to contain_exactly(my_sick_absence.id)
    end

    it "accepts limit by request type travel" do
      list = described_class.list_requests(approver: staff_profile.supervisor,
                                           request_filters: { "request_type" => "travel" }, search_query: nil, order: nil)
      expect(list.map(&:id)).to contain_exactly(my_travel.id)
    end

    it "accepts limit by request type business" do
      my_business_travel = create(:travel_request, creator: staff_profile, travel_category: "business")
      list = described_class.list_requests(approver: staff_profile.supervisor,
                                           request_filters: { "request_type" => "business" }, search_query: nil, order: nil)
      expect(list.map(&:id)).to contain_exactly(my_business_travel.id)
    end

    it "accepts limit by status and request type" do
      my_business_travel = create(:travel_request, creator: staff_profile, action: "fix_requested_changes",
                                                   travel_category: "business")
      create(:travel_request, creator: staff_profile, action: "fix_requested_changes",
                              travel_category: "professional_development")
      list = described_class.list_requests(approver: staff_profile.supervisor,
                                           request_filters: { "request_type" => "business", "status" => "pending" }, search_query: nil, order: nil)
      expect(list.map(&:id)).to contain_exactly(my_business_travel.id)
    end

    context "with changes requested" do
      let(:profile1) { create(:staff_profile, supervisor: profile2) }
      let(:profile2) { create(:staff_profile, supervisor: staff_profile) }
      let(:my_travel) { create(:travel_request, creator: profile1) }

      before do
        my_travel.approve(agent: profile2)
        my_travel.approve(agent: staff_profile)
        my_travel.change_request(agent: staff_profile.supervisor)
        my_travel.fix_requested_changes!(agent: profile1)
      end

      it "returns a success response" do
        list = described_class.list_requests(approver: staff_profile.supervisor, request_filters: nil,
                                             search_query: nil, order: nil)
        expect(list.count).to be(2)
        expect(list.first).to be_a TravelRequest
        expect(list.last).to be_a AbsenceRequest
        expect(list.map(&:id)).to contain_exactly(*[my_absence, my_travel].map(&:id))
      end
    end
  end

  describe "#list_requests with sort params" do
    let(:yesterday) { Time.zone.yesterday }
    let(:today) { Time.zone.today }
    let(:tomorrow) { Time.zone.tomorrow }
    # r1: created yesterday, modified tomorrow, start date today
    let(:r1) do
      Timecop.freeze(yesterday) do
        create(:travel_request, creator: staff_profile, start_date: today)
      end
    end
    # r2: created today, modified yesterday, start date tomorrow
    let(:r2) do
      Timecop.freeze(today) do
        create(:travel_request, creator: staff_profile, start_date: tomorrow)
      end
    end
    # r3: created tomorrow, modified today, start date yesterday
    let(:r3) do
      Timecop.freeze(tomorrow) do
        create(:travel_request, creator: staff_profile, start_date: yesterday)
      end
    end

    before do
      yesterday
      today
      tomorrow
      Timecop.freeze(yesterday) do
        r2.change_request!(agent: staff_profile.department.head)
        r2.fix_requested_changes!(agent: staff_profile)
      end
      r3.change_request!(agent: staff_profile.department.head)
      r3.fix_requested_changes!(agent: staff_profile)
      Timecop.freeze(tomorrow) do
        r1.change_request!(agent: staff_profile.department.head)
        r1.fix_requested_changes!(agent: staff_profile)
      end
    end

    context "sort by start date" do
      it "by default sorts by start date ascending" do
        list = described_class.list_requests(approver: staff_profile.supervisor, request_filters: nil,
                                             search_query: nil, order: nil)
        expect(list.map(&:id)).to eq [r3, r1, r2].map(&:id)
      end

      it "sorts ascending" do
        list = described_class.list_requests(approver: staff_profile.supervisor, request_filters: nil,
                                             search_query: nil, order: "start_date_asc")
        expect(list.map(&:id)).to eq [r3, r1, r2].map(&:id)
      end
    end

    context "sort by date created" do
      it "sorts ascending" do
        list = described_class.list_requests(approver: staff_profile.supervisor, request_filters: nil,
                                             search_query: nil, order: "created_at_asc")
        expect(list.map(&:id)).to eq [r1, r2, r3].map(&:id)
      end

      it "sorts descending" do
        list = described_class.list_requests(approver: staff_profile.supervisor, request_filters: nil,
                                             search_query: nil, order: "created_at_desc")
        expect(list.map(&:id)).to eq [r3, r2, r1].map(&:id)
      end
    end

    context "sort by date modified" do
      it "sorts ascending" do
        list = described_class.list_requests(approver: staff_profile.supervisor, request_filters: nil,
                                             search_query: nil, order: "updated_at_asc")
        expect(list.map(&:id)).to eq [r2, r3, r1].map(&:id)
      end

      it "sorts descending" do
        list = described_class.list_requests(approver: staff_profile.supervisor, request_filters: nil,
                                             search_query: nil, order: "updated_at_desc")
        expect(list.map(&:id)).to eq [r1, r3, r2].map(&:id)
      end
    end
  end

  describe "GET #my_requests with searching" do
    it "retrieves a result" do
      travel_request = create(:travel_request, creator: staff_profile)
      absence_request2 = create(:absence_request, creator: staff_profile, action: :deny)
      travel_request2 = create(:travel_request, creator: staff_profile)
      create(:note, content: "elephants love balloons", request: travel_request)
      create(:note, content: "elephants love balloons", request: absence_request2)
      create(:note, content: "flamingoes are pink because of shrimp", request: travel_request2)

      list = described_class.list_requests(approver: staff_profile.supervisor,
                                           request_filters: { "status" => "pending" }, search_query: "balloons", order: nil)
      expect(list.count).to eq 1
    end

    it "retrieves a result by netid" do
      create(:travel_request, creator: staff_profile)
      create(:absence_request, creator: staff_profile, action: :deny)
      create(:travel_request, creator: staff_profile)

      list = described_class.list_requests(approver: staff_profile.supervisor, request_filters: { "status" => "pending" },
                                           search_query: "abc123", order: nil)
      expect(list.count).to eq 2
    end
  end
end
