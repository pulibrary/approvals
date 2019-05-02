require "rails_helper"

RSpec.describe "absence_requests/edit", type: :view do
  let(:creator) { FactoryBot.create(:staff_profile) }
  let(:absence_request) { AbsenceRequest.create!(creator_id: creator.id) }
  before do
    @absence_request = assign(:absence_request, absence_request)
  end

  it "renders the edit absence_request form" do
    render

    assert_select "form[action=?][method=?]", absence_request_path(absence_request), "post" do
    end
  end
end
