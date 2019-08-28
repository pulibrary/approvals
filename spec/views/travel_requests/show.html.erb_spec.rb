# frozen_string_literal: true
require "rails_helper"

RSpec.describe "travel_requests/show", type: :view do
  let(:travel_request) { FactoryBot.create(:travel_request, :with_note_and_estimate) }
  before do
    @travel_request = assign(:travel_request, TravelRequestDecorator.new(travel_request))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to include(travel_request.creator.given_name)
    expect(rendered).to match(/#{ travel_request.start_date.to_s}/)
    expect(rendered).to match(/#{ travel_request.end_date.to_s}/)
    expect(rendered).to match(/#{ travel_request.purpose}/)
    expect(rendered).to match(/#{ travel_request.participation}/)
    expect(rendered).to match(/#{ travel_request.travel_category}/)
    expect(rendered).to match(/wants to attend/)
    expect(rendered).to include(travel_request.notes.first.content)
    expect(rendered).to match(/#{ travel_request.estimates.first.cost_type}/)
    expect(rendered).to match(/#{ travel_request.estimates.first.amount}/)
    expect(rendered).to match(/#{ travel_request.estimates.first.recurrence}/)
  end
end
