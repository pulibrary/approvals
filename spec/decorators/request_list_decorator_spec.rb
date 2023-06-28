# frozen_string_literal: true
require "rails_helper"
RSpec.describe RequestListDecorator, type: :model do
  subject(:request_list_decorator) { described_class.new([FactoryBot.create(:absence_request)], params_hash: params_hash) }
  let(:params_hash) { {} }

  describe "attributes relevant to list" do
    it { is_expected.to respond_to :each }
    it { is_expected.to respond_to :to_a }
    it { is_expected.to respond_to :map }
    it { is_expected.to respond_to :count }
    it { is_expected.to respond_to :first }
    it { is_expected.to respond_to :last }
  end

  describe "#first" do
    it "returns AbsenceRequestDecorators for absence request objects" do
      expect(request_list_decorator.first).to be_a AbsenceRequestDecorator
    end
  end

  describe "#status_filter_urls" do
    let(:approved_filter) { "/my_requests?#{travel_filter}filters%5Bstatus%5D=approved#{sort}" }
    let(:canceled_filter) { "/my_requests?#{travel_filter}filters%5Bstatus%5D=canceled#{sort}" }
    let(:changes_requested_filter) { "/my_requests?#{travel_filter}filters%5Bstatus%5D=changes_requested#{sort}" }
    let(:denied_filter) { "/my_requests?#{travel_filter}filters%5Bstatus%5D=denied#{sort}" }
    let(:pending_filter) { "/my_requests?#{travel_filter}filters%5Bstatus%5D=pending#{sort}" }
    let(:recorded_filter) { "/my_requests?#{travel_filter}filters%5Bstatus%5D=recorded#{sort}" }
    let(:travel_filter) { "" }
    let(:sort) { "" }
    let(:filters) do
      {
        "Approved" => approved_filter,
        "Changes requested" => changes_requested_filter,
        "Canceled" => canceled_filter,
        "Denied" => denied_filter,
        "Pending" => pending_filter,
        "Recorded" => recorded_filter
      }
    end

    it "returns a list of status filter urls" do
      expect(request_list_decorator.status_filter_urls).to eq(filters)
    end

    context "a travel filter has been applied" do
      let(:travel_filter) { "filters%5Brequest_type%5D=travel&" }
      let(:params_hash) { { "filters" => { "request_type" => "travel" } } }

      it "returns a list of status filter urls that include the travel filter" do
        expect(request_list_decorator.status_filter_urls).to eq(filters)
      end
    end

    context "a status and travel filter has been applied" do
      let(:travel_filter) { "filters%5Brequest_type%5D=travel&" }
      let(:params_hash) { { "filters" => { "request_type" => "travel", "status" => "approved" } } }

      it "returns a list of status filter urls that include the travel filter, but not the old status filter" do
        expect(request_list_decorator.status_filter_urls).to eq(filters)
      end
    end

    context "a sort has been applied" do
      let(:sort) { "&sort=start_date_asc" }
      let(:params_hash) { { "sort" => "start_date_asc" } }

      it "returns a list of status filter urls that include the sort" do
        expect(request_list_decorator.status_filter_urls).to eq(filters)
      end
    end

    context "a sort has been applied, and a status and travel filter has been applied" do
      let(:sort) { "&sort=start_date_asc" }
      let(:travel_filter) { "filters%5Brequest_type%5D=travel&" }
      let(:params_hash) { { "sort" => "start_date_asc", "filters" => { "request_type" => "travel", "status" => "approved" } } }

      it "returns a list of status filter urls that include the travel filter, but not the old status filter" do
        expect(request_list_decorator.status_filter_urls).to eq(filters)
      end
    end
  end

  describe "#absence_filter_url" do
    it "returns an absence filter url" do
      expect(request_list_decorator.absence_filter_url).to eq("/my_requests?filters%5Brequest_type%5D=absence")
    end
  end

  describe "#absence_filter_urls" do
    let(:vacation_filter) { "/my_requests?filters%5Brequest_type%5D=vacation#{status_filter}" }
    let(:sick_filter) { "/my_requests?filters%5Brequest_type%5D=sick#{status_filter}" }
    let(:personal_filter) { "/my_requests?filters%5Brequest_type%5D=personal#{status_filter}" }
    let(:research_days_filter) { "/my_requests?filters%5Brequest_type%5D=research_days#{status_filter}" }
    let(:consulting_filter) { "/my_requests?filters%5Brequest_type%5D=consulting#{status_filter}" }
    let(:jury_duty_filter) { "/my_requests?filters%5Brequest_type%5D=jury_duty#{status_filter}" }
    let(:death_in_family_filter) { "/my_requests?filters%5Brequest_type%5D=death_in_family#{status_filter}" }

    let(:status_filter) { "" }
    let(:filters) do
      {
        "Vacation" => vacation_filter,
        "Sick" => sick_filter,
        "Personal" => personal_filter,
        "Research days" => research_days_filter,
        "Consulting" => consulting_filter,
        "Jury duty" => jury_duty_filter,
        "Death in family" => death_in_family_filter
      }
    end

    it "returns a list of absence filter urls" do
      expect(request_list_decorator.absence_filter_urls).to eq(filters)
    end

    context "a status filter has been applied" do
      let(:status_filter) { "&filters%5Bstatus%5D=approved" }
      let(:params_hash) { { "filters" => { "status" => "approved" } } }

      it "returns a list of absence filter urls that include the status filter" do
        expect(request_list_decorator.absence_filter_urls).to eq(filters)
      end
    end

    context "a status filter and travel filter has been applied" do
      let(:status_filter) { "&filters%5Bstatus%5D=approved" }
      let(:params_hash) { { "filters" => { "request_type" => "travel", "status" => "approved" } } }
      it "returns a list of absence filter urls that include the status filter, but not the request type filter" do
        expect(request_list_decorator.absence_filter_urls).to eq(filters)
      end
    end
  end

  describe "#travel_filter_url" do
    it "returns an travel filter url " do
      expect(request_list_decorator.travel_filter_url).to eq("/my_requests?filters%5Brequest_type%5D=travel")
    end
  end

  describe "#travel_filter_urls" do
    let(:business_filter) { "/my_requests?filters%5Brequest_type%5D=business#{status_filter}" }
    let(:professional_development_filter) { "/my_requests?filters%5Brequest_type%5D=professional_development#{status_filter}" }

    let(:status_filter) { "" }
    let(:filters) do
      {
        "Acquisitions" => "/my_requests?filters%5Brequest_type%5D=acquisitions#{status_filter}",
        "Business" => business_filter,
        "Conferences" => "/my_requests?filters%5Brequest_type%5D=conferences#{status_filter}",
        "Education and training" => "/my_requests?filters%5Brequest_type%5D=education_and_training#{status_filter}",
        "Professional development" => professional_development_filter,
        "Required business" => "/my_requests?filters%5Brequest_type%5D=required_business#{status_filter}"
      }
    end

    it "returns a list of travel filter urls" do
      expect(request_list_decorator.travel_filter_urls).to eq(filters)
    end

    context "a status filter has been applied" do
      let(:status_filter) { "&filters%5Bstatus%5D=approved" }
      let(:params_hash) { { "filters" => { "status" => "approved" } } }

      it "returns a list of travel filter urls that include the status filter" do
        expect(request_list_decorator.travel_filter_urls).to eq(filters)
      end
    end

    context "a status filter and request filter applied" do
      let(:status_filter) { "&filters%5Bstatus%5D=approved" }
      let(:params_hash) { { "filters" => { "request_type" => "travel", "status" => "approved" } } }

      it "returns a list of travel filter urls that include the status filter, but not the request type filter" do
        expect(request_list_decorator.travel_filter_urls).to eq(filters)
      end
    end
  end

  describe "#filter_removal_urls" do
    it "returns an empty list when no filters are selected" do
      expect(request_list_decorator.filter_removal_urls).to eq({})
    end

    context "approved filter applied" do
      let(:params_hash) { { "filters" => { "status" => "approved" } } }
      it "returns a link to clear the approved status filter" do
        expect(request_list_decorator.filter_removal_urls).to eq("Status: Approved" => "/my_requests")
      end
    end

    context "travel filter applied" do
      let(:params_hash) { { "filters" => { "request_type" => "travel" } } }
      it "returns a link to clear the approved status filter" do
        expect(request_list_decorator.filter_removal_urls).to eq("Request type: Travel" => "/my_requests")
      end
    end

    context "approved and travel filter applied" do
      let(:params_hash) { { "filters" => { "status" => "approved", "request_type" => "travel" } } }
      it "returns a link to clear the approved status filter" do
        expect(request_list_decorator.filter_removal_urls).to eq(
          "Request type: Travel" => "/my_requests?filters%5Bstatus%5D=approved",
          "Status: Approved" => "/my_requests?filters%5Brequest_type%5D=travel"
        )
      end
    end

    context "sort applied" do
      let(:params_hash) { { "sort" => "start_date_desc", "filters" => { "status" => "approved" } } }

      it "returns a link that retains the sort while removing the filter" do
        expect(request_list_decorator.filter_removal_urls).to eq("Status: Approved" => "/my_requests?sort=start_date_desc")
      end
    end

    context "sort applied, approved and travel filter applied" do
      let(:params_hash) { { "sort" => "start_date_desc", "filters" => { "status" => "approved", "request_type" => "travel" } } }

      it "returns a link that retains the sort while removing the filter" do
        expect(request_list_decorator.filter_removal_urls).to eq(
          "Request type: Travel" =>
            "/my_requests?filters%5Bstatus%5D=approved&sort=start_date_desc",
          "Status: Approved" =>
            "/my_requests?filters%5Brequest_type%5D=travel&sort=start_date_desc"
        )
      end
    end
  end

  describe "current_status_filter_label" do
    it "returns default when no filter is applied" do
      expect(request_list_decorator.current_status_filter_label).to eq("Status")
    end
  end

  describe "current_request_type_filter_label" do
    it "returns default when no filter is applied" do
      expect(request_list_decorator.current_request_type_filter_label).to eq("Request type")
    end
  end

  describe "sort_urls" do
    let(:start_date_ascending) { "/my_requests?#{filters}sort=start_date_asc" }
    let(:start_date_descending) { "/my_requests?#{filters}sort=start_date_desc" }
    let(:created_at_ascending) { "/my_requests?#{filters}sort=created_at_asc" }
    let(:created_at_descending) { "/my_requests?#{filters}sort=created_at_desc" }
    let(:updated_at_ascending) { "/my_requests?#{filters}sort=updated_at_asc" }
    let(:updated_at_descending) { "/my_requests?#{filters}sort=updated_at_desc" }
    let(:filters) { "" }
    let(:sort_urls) do
      {
        "Start date - ascending" => start_date_ascending,
        "Start date - descending" => start_date_descending,
        "Date created - ascending" => created_at_ascending,
        "Date created - descending" => created_at_descending,
        "Date modified - ascending" => updated_at_ascending,
        "Date modified - descending" => updated_at_descending
      }
    end
    it "returns a list of sort urls" do
      expect(request_list_decorator.sort_urls).to eq sort_urls
    end

    context "we have have status and request type filters applied" do
      let(:filters) { "filters%5Brequest_type%5D=business&filters%5Bstatus%5D=approved&" }
      let(:params_hash) { { "filters" => { "request_type" => "business", "status" => "approved" } } }

      it "returns a list of sort urls that include the filters" do
        expect(request_list_decorator.sort_urls).to eq sort_urls
      end
    end
  end

  describe "current_sort_label" do
    it "returns default when no sort is applied" do
      expect(request_list_decorator.current_sort_label).to eq("Sort: Date modified - descending")
    end

    context "when a sort param is provided" do
      let(:params_hash) { { "sort" => "start_date_asc" } }
      it "returns desired string" do
        expect(request_list_decorator.current_sort_label).to eq("Sort: Start date - ascending")
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
