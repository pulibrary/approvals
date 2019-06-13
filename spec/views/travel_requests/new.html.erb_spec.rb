# frozen_string_literal: true
require "rails_helper"

RSpec.describe "travel_requests/new", type: :view do
  let(:travel_request) do
    FactoryBot.build(:travel_request, purpose: "my grand purpose",
                                      participation: "presenter",
                                      travel_category: "business")
  end
  before do
    assign(:travel_request, travel_request)
  end

  it "renders new travel_request form" do
    render

    assert_select "form[action=?][method=?]", travel_requests_path, "post" do
      assert_select "input[name=?][value=?]", "travel_request[creator_id]", travel_request.creator_id.to_s
      assert_select "input[name=?][value=?]", "travel_request[start_date]", travel_request.start_date.to_s
      assert_select "input[name=?][value=?]", "travel_request[end_date]", travel_request.end_date.to_s
      assert_select "input[name=?][value=?]", "travel_request[purpose]", travel_request.purpose
      assert_select "input[name=?][value=?]", "travel_request[participation]", travel_request.participation
    end
  end
end
