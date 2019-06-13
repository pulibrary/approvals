# frozen_string_literal: true
require "rails_helper"

RSpec.describe "absence_requests/new", type: :view do
  let(:absence_request) do
    FactoryBot.build(:absence_request, purpose: "my grand purpose",
                                       absence_type: "vacation")
  end
  before do
    assign(:absence_request_change_set, AbsenceRequestChangeSet.new(absence_request))
  end

  it "renders new absence_request form" do
    render

    assert_select "form[action=?][method=?]", absence_requests_path, "post" do
      assert_select "input[name=?][value=?]", "absence_request[creator_id]", absence_request.creator_id.to_s
      assert_select "input[name=?][value=?]", "absence_request[start_date]", absence_request.start_date.to_s
      assert_select "input[name=?][value=?]", "absence_request[end_date]", absence_request.end_date.to_s
      assert_select "input-select[name=?][value=?]", "absence_request[absence_type]", absence_request.absence_type
    end
  end
end
