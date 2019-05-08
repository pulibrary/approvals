require "rails_helper"

RSpec.describe "travel_requests/show", type: :view do
  let(:travel_request) { FactoryBot.create(:travel_request) }
  before do
    @travel_request = assign(:travel_request, travel_request)
  end

  it "renders attributes in <p>" do
    render
  end
end
