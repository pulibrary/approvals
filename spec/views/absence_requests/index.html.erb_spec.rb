require "rails_helper"

RSpec.describe "absence_requests/index", type: :view do
  before do
    assign(:absence_requests, [
             FactoryBot.create(:absence_request),
             FactoryBot.create(:absence_request)
           ])
  end

  it "renders a list of absence_requests" do
    render
  end
end
