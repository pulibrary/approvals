# frozen_string_literal: true
require "rails_helper"

RSpec.describe "travel_requests/edit", type: :view do
  let(:travel_request) do
    FactoryBot.create(:travel_request, purpose: "my grand purpose",
                                       participation: "presenter",
                                       travel_category: "business")
  end
  before do
    assign(:request_change_set, TravelRequestChangeSet.new(travel_request))
  end

  it "renders the edit travel_request form" do
    render

    assert_select "form[action=?][method=?]", travel_request_path(travel_request), "post" do
      assert_select "date-picker[label=?][mode=?][name=?]", "Event Dates", "range", "travel_request[event_requests_attributes][0][event_dates]"
      assert_select "date-picker[label=?][mode=?][name=?]", "Travel Dates", "range", "travel_request[travel_dates]"
      assert_select "input-select[name=?][value=?]", "travel_request[participation]", "presenter"
      assert_select "input-text[name=?]", "notes"
      assert_select "input-text[name=?][value=?]", "travel_request[purpose]", travel_request.purpose
      assert_select "input-text[name=?][value=?]", "travel_request[event_requests_attributes][0][location]", travel_request.event_requests[0].location
      assert_select 'input-button[type="submit"]'
    end
  end
end
