# frozen_string_literal: true
require "rails_helper"

RSpec.describe "absence_requests/new", type: :view do
  let(:absence_request) do
    FactoryBot.build(:absence_request, absence_type: "vacation")
  end
  before do
    assign(:request_change_set, AbsenceRequestChangeSet.new(absence_request, start_date: Date.parse("2019-12-23"), end_date: Date.parse("2019-12-27")))
  end

  it "renders new absence_request form" do
    without_partial_double_verification do
      allow(view).to receive(:current_staff_profile).and_return(absence_request.creator)
      render

      assert_select "form[action=?][method=?]", absence_requests_path, "post" do
        assert_select "hours-calculator[start-date=?][end-date=?]", "12/23/2019", "12/27/2019"
        assert_select "input-select[name=?][value=?]", "absence_request[absence_type]", absence_request.absence_type
        assert_select "input-text[name=?]", "absence_request[notes][content]"
        assert_select 'input-button[type="submit"]'
      end
    end
  end
end
