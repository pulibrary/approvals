# frozen_string_literal: true
require "rails_helper"

RSpec.describe "travel_requests/show", type: :view do
  let(:creator) { FactoryBot.create(:staff_profile, :with_supervisor, given_name: "Sally", surname: "Smith") }
  let(:travel_request) { TravelRequestDecorator.new(FactoryBot.create(:travel_request, :with_note_and_estimate, creator: creator)) }
  before do
    @request = assign(:request, travel_request)
  end

  it "renders attributes in <p>" do
    without_partial_double_verification do
      allow(view).to receive(:current_staff_profile).and_return(creator)
      render
    end
    expect(rendered).to include(travel_request.creator.given_name)
    expect(rendered).to match(/#{travel_request.formatted_full_start_date}/)
    expect(rendered).to match(/#{travel_request.formatted_full_end_date}/)
    expect(rendered).to match(/#{travel_request.purpose}/)
    expect(rendered).to match(/#{travel_request.participation}/)
    expect(rendered).to match(/#{travel_request.travel_category}/)
    expect(rendered).to match(/Sally Smith/)
    expect(rendered).to include("Sally Smith on")
    expect(rendered).to include(travel_request.notes.first.content)
    expect(rendered).to include("Lodging (per night)")
    expect(rendered).to match(/#{travel_request.estimates.first.amount}/)
    expect(rendered).to match(/#{travel_request.estimates.first.recurrence}/)
    expect(rendered).to have_selector("lux-hyperlink[href=\"#{edit_travel_request_path(travel_request.request)}\"]", text: "Edit")
    expect(rendered).to have_selector("form[action=\"#{decide_travel_request_path(travel_request.id)}\"]")
    expect(rendered).to have_selector("lux-input-button", text: "Cancel")
  end

  it "does not render edit if current profile is not the creator" do
    without_partial_double_verification do
      allow(view).to receive(:current_staff_profile).and_return(FactoryBot.create(:staff_profile))
      render
    end
    expect(rendered).not_to have_selector("hyperlink[href=\"#{edit_travel_request_path(travel_request.request)}\"]", text: "Edit")
    expect(rendered).not_to have_selector("form[action=\"#{decide_travel_request_path(travel_request.id)}\"]")
  end
end
