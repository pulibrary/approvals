require "rails_helper"

RSpec.describe "absence_requests/edit", type: :view do
  let(:absence_request) do
    FactoryBot.create(:absence_request, purpose: "my grand purpose",
                                        absence_type: "vacation_monthly")
  end
  before do
    assign(:absence_request, absence_request)
  end

  it "renders the edit absence_request form" do
    render

    assert_select "form[action=?][method=?]", absence_request_path(absence_request), "post" do
      assert_select "input[name=?][value=?]", "absence_request[creator_id]", absence_request.creator_id.to_s
      assert_select "input[name=?][value=?]", "absence_request[start_date]", absence_request.start_date.to_s
      assert_select "input[name=?][value=?]", "absence_request[end_date]", absence_request.end_date.to_s
      assert_select "input[name=?][value=?]", "absence_request[absence_type]", absence_request.absence_type
    end
  end
end
