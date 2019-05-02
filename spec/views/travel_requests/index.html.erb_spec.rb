require "rails_helper"

RSpec.describe "travel_requests/index", type: :view do
  let(:creator) { FactoryBot.create(:staff_profile) }
  before do
    assign(:travel_requests, [
             TravelRequest.create!(
               creator_id: creator.id
             ),
             TravelRequest.create!(
               creator_id: creator.id
             )
           ])
  end

  it "renders a list of travel_requests" do
    render
  end
end
