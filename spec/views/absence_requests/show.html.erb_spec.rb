require "rails_helper"

RSpec.describe "absence_requests/show", type: :view do
  let(:creator) { FactoryBot.create(:user) }
  let(:absence_request) { AbsenceRequest.create!(creator_id: creator.id) }
  before do
    @absence_request = assign(:absence_request, absence_request)
  end

  it "renders attributes in <p>" do
    render
  end
end
