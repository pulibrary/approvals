require "rails_helper"

RSpec.describe "absence_requests/edit", type: :view do
  let(:absence_request) { FactoryBot.create(:absence_request) }
  before do
    @absence_request = assign(:absence_request, absence_request)
  end

  it "renders the edit absence_request form" do
    render

    assert_select "form[action=?][method=?]", absence_request_path(absence_request), "post" do
    end
  end
end
