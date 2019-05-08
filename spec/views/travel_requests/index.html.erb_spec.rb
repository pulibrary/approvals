require "rails_helper"

RSpec.describe "travel_requests/index", type: :view do
  let(:creator) { FactoryBot.create(:staff_profile) }
  let(:travel_request1) do
    FactoryBot.create(:travel_request, purpose: "my grand purpose",
                                       participation: "presenter",
                                       travel_category: "business")
  end
  let(:travel_request2) do
    FactoryBot.create(:travel_request, purpose: "Another reson to go",
                                       participation: "other",
                                       travel_category: "professional_development")
  end
  before do
    assign(:travel_requests, [travel_request1, travel_request2])
  end

  it "renders a list of travel_requests" do
    render
    assert_select "tr>td", text: travel_request1.creator.to_s
    assert_select "tr>td", text: travel_request2.creator.to_s
    assert_select "tr>td", text: travel_request1.start_date.to_s
    assert_select "tr>td", text: travel_request2.start_date.to_s
    assert_select "tr>td", text: travel_request1.end_date.to_s
    assert_select "tr>td", text: travel_request2.end_date.to_s
    assert_select "tr>td", text: travel_request1.status
    assert_select "tr>td", text: travel_request2.status
    assert_select "tr>td", text: travel_request1.purpose
    assert_select "tr>td", text: travel_request2.purpose
    assert_select "tr>td", text: travel_request1.participation
    assert_select "tr>td", text: travel_request2.participation
    assert_select "tr>td", text: travel_request1.travel_category
    assert_select "tr>td", text: travel_request2.travel_category
  end
end
