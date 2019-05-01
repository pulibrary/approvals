require "rails_helper"

RSpec.describe "travel_requests/show", type: :view do
  let(:creator) { FactoryBot.create(:user) }
  let(:travel_request) { TravelRequest.create!(creator_id: creator.id) }
  before do
    @travel_request = assign(:travel_request, travel_request)
  end

  it "renders attributes in <p>" do
    render
  end
end
