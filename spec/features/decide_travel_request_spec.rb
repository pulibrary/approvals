# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Review Travel Request", type: :feature, js: true do
  let(:user) { create(:user) }
  let(:department_head) do
    profile = create(:staff_profile, user: user, given_name: "Sally", surname: "Smith")
    create(:department, head: profile)
    profile
  end
  let(:staff_profile) do
    create(:staff_profile, department: department_head.department, given_name: "John", surname: "Doe",
                           supervisor: department_head)
  end
  let(:event_with_target_name) do
    build(
      :event_request,
      recurring_event: build(:recurring_event, name: "Different test name")
    )
  end
  let(:travel_request_with_target_event_name) do
 create(:travel_request, event_requests: [event_with_target_name])
  end

  let(:travel_request) { create(:travel_request, creator: staff_profile) }

  before do
    sign_in user
  end

  it "I can approve a travel request" do
    visit "/travel_requests/#{travel_request.id}/review"
    fill_in "travel_request_notes_content", with: "Make Changes"

    click_on "Request Changes"
    expect(page).to have_content "Travel request was successfully updated."
    expect(page).to have_content "Changes requested"

    # the user fixes the issues in the background
    travel_request.reload
    travel_request.fix_requested_changes!(agent: staff_profile)

    # Approve the request
    visit "/travel_requests/#{travel_request.id}/review"

    fill_in "travel_request_notes_content", with: "Elephants Love Balloons"
    click_on "Approve"
    expect(page).to have_content "Travel category is required to approve."
    find("#travel_request_travel_category option[value='acquisitions']").select_option
    click_on "Approve"
    expect(page).to have_content "Travel request was successfully updated."
    expect(page).to have_content "Approved"
    expect(page).to have_content "Elephants Love Balloons"
  end

  it "I can change the event title of a travel request" do
    travel_request_with_target_event_name

    visit "/travel_requests/#{travel_request.id}/review"

    expect(page.find(:css, ".event-title").text).to include("Event", "#{DateTime.now.year}, Location")
    fill_in("displayInput", with: "D")
    event_titles = page.find_all("li", text: "Different")
    expect(event_titles.size).to eq(1)
    event_titles.first.select_option
    click_on "Change Event Name"
    expect(page).to have_content "Travel request event name was successfully updated."

    expect(page.find(:css, ".event-title").text).to include("Different test name #{DateTime.now.year}, Location")
    find("#travel_request_travel_category option[value='acquisitions']").select_option
    click_on "Approve"
    expect(page).to have_content "Travel request was successfully updated."
    expect(page).to have_content "Approved"
  end

  it "I cannot change the event title of a travel request to an empty string" do
    visit "/travel_requests/#{travel_request.id}/review"

    expect(travel_request.event_title).to match(/Event \d* \d*, Location/)
    fill_in("displayInput", with: "")
    # The autocomplete dropdown covers the buttons so hit tab to clear
    find("#displayInput").send_keys(:tab)
    click_on "Change Event Name"
    expect(travel_request.reload.event_title).to match(/Event \d* \d*, Location/)
    expect(page).to have_content("is required to specify requested changes")
  end

  it "I cannot change the event title of a travel request to an arbitrary string" do
    visit "/travel_requests/#{travel_request.id}/review"

    expect(travel_request.event_title).to match(/Event \d* \d*, Location/)
    fill_in("displayInput", with: "Random text")
    # The autocomplete dropdown covers the buttons so hit tab to clear
    find("#displayInput").send_keys(:tab)
    click_on "Change Event Name"
    expect(travel_request.reload.event_title).to match(/Event \d* \d*, Location/)
    expect(page).to have_content("Event name does not exist, please select an existing event name.")
  end
end
