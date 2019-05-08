require "rails_helper"

RSpec.describe "absence_requests/show", type: :view do
  let(:absence_request) { FactoryBot.create(:absence_request) }
  before do
    @absence_request = assign(:absence_request, absence_request)
  end

  it "renders attributes in <p>" do
    render
  end
end
