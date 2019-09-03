# frozen_string_literal: true
require "rails_helper"

RSpec.describe "travel_requests/show", type: :view do
  let(:creator) { FactoryBot.create(:staff_profile, :with_supervisor, given_name: "Sally", surname: "Smith") }
  let(:travel_request) { FactoryBot.create(:travel_request, :with_note_and_estimate, creator: creator) }
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
    expect(rendered).to match(/Sally wants to attend/)
    expect(rendered).to include("Notes from Sally Smith")
    expect(rendered).to include(travel_request.notes.first.content)
    expect(rendered).to match(/#{ travel_request.estimates.first.cost_type}/)
    expect(rendered).to match(/#{ travel_request.estimates.first.amount}/)
    expect(rendered).to match(/#{ travel_request.estimates.first.recurrence}/)
    expect(rendered).to have_selector("hyperlink[href=\"#{edit_travel_request_path(travel_request)}\"]", text: "Edit")
    expect(rendered).to have_selector("hyperlink[href=\"#{my_requests_path}\"]", text: "Back")
  end
end
