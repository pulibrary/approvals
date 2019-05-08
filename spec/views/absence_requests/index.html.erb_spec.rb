require "rails_helper"

RSpec.describe "absence_requests/index", type: :view do
  let(:absence_request1) do
    FactoryBot.create(:absence_request, purpose: "my grand purpose",
                                        absence_type: "personal")
  end
  let(:absence_request2) do
    FactoryBot.create(:absence_request, purpose: "Another reson to go",
                                        absence_type: "jury_duty")
  end
  before do
    assign(:absence_requests, [absence_request1, absence_request2])
  end

  it "renders a list of absence_requests" do
    render
    assert_select "tr>td", text: absence_request1.creator.to_s
    assert_select "tr>td", text: absence_request2.creator.to_s
    assert_select "tr>td", text: absence_request1.start_date.to_s
    assert_select "tr>td", text: absence_request2.start_date.to_s
    assert_select "tr>td", text: absence_request1.end_date.to_s
    assert_select "tr>td", text: absence_request2.end_date.to_s
    assert_select "tr>td", text: absence_request1.participation
    assert_select "tr>td", text: absence_request2.participation
    assert_select "tr>td", text: absence_request1.status
    assert_select "tr>td", text: absence_request2.status
    assert_select "tr>td", text: absence_request1.absence_type
    assert_select "tr>td", text: absence_request2.absence_type
  end
end
