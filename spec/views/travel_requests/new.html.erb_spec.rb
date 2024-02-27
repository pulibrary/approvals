# frozen_string_literal: true
require "rails_helper"

RSpec.describe "travel_requests/new", type: :view do
  let(:travel_request) do
    FactoryBot.build(:travel_request, purpose: "my grand purpose",
                                      participation: "presenter",
                                      travel_category: "business")
  end
  before do
    assign(:request_change_set, TravelRequestChangeSet.new(travel_request))
  end

  it "renders new travel_request form" do
    render
    assert_select "form[action=?][method=?]", travel_requests_path, "post" do
      assert_select "travel-request-date-pickers"
      assert_select "lux-input-select[name=?][value=?]", "travel_request[participation]", "presenter"
      assert_select "lux-input-text[name=?]", "travel_request[notes][][content]"
      assert_select "lux-input-text[name=?][value=?]", "travel_request[purpose]", travel_request.purpose
      assert_select "lux-input-text[name=?][value=?]", "travel_request[event_requests_attributes][0][location]", travel_request.event_requests[0].location
      assert_select "travel-request-button"
    end
  end
end
