require "rails_helper"

RSpec.describe "travel_requests/index", type: :view do
  let(:creator) { FactoryBot.create(:staff_profile) }
  before do
    assign(:travel_requests, [
             FactoryBot.create(:travel_request),
             FactoryBot.create(:travel_request)
           ])
  end

  it "renders a list of travel_requests" do
    render
  end
end
