require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe RequestListDecorator, type: :model do
  subject(:request_list_decorator) { described_class.new([FactoryBot.create(:absence_request)], params: params) }
  let(:params) { ActionController::Parameters.new(param_hash) }
  let(:empty_params) { ActionController::Parameters.new({}) }
  let(:param_hash) { {} }

  describe "attributes relevant to absence requests" do
    it { is_expected.to respond_to :each }
    it { is_expected.to respond_to :to_a }
  end

  describe "#status_filter_urls" do
    let(:pending_filter) { "/my_requests?#{travel_filter}filters%5Bstatus%5D=pending" }
    let(:approved_filter) { "/my_requests?#{travel_filter}filters%5Bstatus%5D=approved" }
    let(:denied_filter) { "/my_requests?#{travel_filter}filters%5Bstatus%5D=denied" }
    let(:changes_requested_filter) { "/my_requests?#{travel_filter}filters%5Bstatus%5D=changes_requested" }
    let(:travel_filter) { "" }
    let(:filters) do
      {
        "Pending" => pending_filter,
        "Approved" => approved_filter,
        "Denied" => denied_filter,
        "Changes requested" => changes_requested_filter
      }
    end

    it "returns a list of status filter urls for display in the status filter dropdown menu" do
      expect(request_list_decorator.status_filter_urls).to eq(filters)
    end

    context "a travel filter has been applied" do
      let(:travel_filter) { "filters%5Brequest_type%5D=travel&" }
      let(:param_hash) { { "filters" => { "request_type" => "travel" } } }

      it "returns a list of status filter urls that include the travel filter" do
        expect(request_list_decorator.status_filter_urls).to eq(filters)
      end
    end

    context "a status and travel filter has been applied" do
      let(:travel_filter) { "filters%5Brequest_type%5D=travel&" }
      let(:param_hash) { { "filters" => { "request_type" => "travel", "status" => "approved" } } }

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
    let(:work_from_home_filter) { "/my_requests?filters%5Brequest_type%5D=work_from_home#{status_filter}" }
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
        "Work from home" => work_from_home_filter,
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
      let(:param_hash) { { "filters" => { "status" => "approved" } } }

      it "returns a list of absence filter urls that include the status filter" do
        expect(request_list_decorator.absence_filter_urls).to eq(filters)
      end
    end

    context "a status filter and travel filter has been applied" do
      let(:status_filter) { "&filters%5Bstatus%5D=approved" }
      let(:param_hash) { { "filters" => { "request_type" => "travel", "status" => "approved" } } }
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
    let(:discretionary_filter) { "/my_requests?filters%5Brequest_type%5D=discretionary#{status_filter}" }

    let(:status_filter) { "" }
    let(:filters) do
      {
        "Business" => business_filter,
        "Professional development" => professional_development_filter,
        "Discretionary" => discretionary_filter
      }
    end

    it "returns a list of travel filter urls" do
      expect(request_list_decorator.travel_filter_urls).to eq(filters)
    end

    context "a status filter has been applied" do
      let(:status_filter) { "&filters%5Bstatus%5D=approved" }
      let(:param_hash) { { "filters" => { "status" => "approved" } } }

      it "returns a list of travel filter urls that include the status filter" do
        expect(request_list_decorator.travel_filter_urls).to eq(filters)
      end
    end

    context "a status filter and request filter applied" do
      let(:status_filter) { "&filters%5Bstatus%5D=approved" }
      let(:param_hash) { { "filters" => { "request_type" => "travel", "status" => "approved" } } }

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
      let(:param_hash) { { "filters" => { "status" => "approved" } } }
      it "returns a link to clear the approved status filter" do
        expect(request_list_decorator.filter_removal_urls).to eq("Status: Approved" => "/my_requests")
      end
    end

    context "travel filter applied" do
      let(:param_hash) { { "filters" => { "request_type" => "travel" } } }
      it "returns a link to clear the approved status filter" do
        expect(request_list_decorator.filter_removal_urls).to eq("Request type: Travel" => "/my_requests")
      end
    end

    context "approved and travel filter applied" do
      let(:param_hash) { { "filters" => { "status" => "approved", "request_type" => "travel" } } }
      it "returns a link to clear the approved status filter" do
        expect(request_list_decorator.filter_removal_urls).to eq(
          "Request type: Travel" => "/my_requests?filters%5Bstatus%5D=approved",
          "Status: Approved" => "/my_requests?filters%5Brequest_type%5D=travel"
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
end
# rubocop:enable Metrics/BlockLength
