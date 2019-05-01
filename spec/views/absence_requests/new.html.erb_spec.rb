require "rails_helper"

RSpec.describe "absence_requests/new", type: :view do
  before do
    assign(:absence_request, AbsenceRequest.new)
  end

  it "renders new absence_request form" do
    render

    assert_select "form[action=?][method=?]", absence_requests_path, "post" do
    end
  end
end
