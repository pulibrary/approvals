require "rails_helper"

RSpec.describe "travel_requests/edit", type: :view do
  let(:creator) { FactoryBot.create(:user) }
  let(:travel_request) { TravelRequest.create!(creator_id: creator.id) }
  before do
    @travel_request = assign(:travel_request, travel_request)
  end

  it "renders the edit travel_request form" do
    render

    assert_select "form[action=?][method=?]", travel_request_path(travel_request), "post" do
    end
  end
end
