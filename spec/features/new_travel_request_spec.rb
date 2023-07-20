# frozen_string_literal: true
require "rails_helper"

RSpec.feature "New Travel Request", type: :feature, js: true do
  let(:user) { FactoryBot.create :user }
  let(:staff_profile) do
    FactoryBot.create :staff_profile, :with_department, user: user, given_name: "Sally", surname: "Smith",
                                                        vacation_balance: 90.1, personal_balance: 16.0, sick_balance: 100.0
  end

  before do
    sign_in user
    staff_profile
  end

  context "with other created events" do
    let(:travel_request_1) { FactoryBot.create(:travel_request) }
    let(:travel_request_2) { FactoryBot.create(:travel_request) }
    before do
      travel_request_1
      travel_request_2
    end
    it "can autocomplete the Event Name" do
      visit "/travel_requests/new"

      fill_in "displayInput", with: "e"
      event_titles = page.find_all("li", text: "Event")
      expect(event_titles.size).to eq(2)
      event_titles.first.select_option

      fill_in "travel_request_event_requests_attributes_0_event_dates", with: "10/1/2019 - 10/3/2019"
      fill_in "travel_request_travel_dates", with: "10/1/2019 - 10/3/2019"
      fill_in "travel_request_event_requests_attributes_0_location", with: "A Place To Be"
      find("#travel_request_participation option[value='other']").select_option
      fill_in "travel_request_purpose", with: "A grand purpose"
      find("select[id^='travel_request_estimates_cost_type_'] option[value='air']").select_option
      find("input[id^='travel_request_estimates_recurrence_']").fill_in with: "2"
      find("input[id^='travel_request_estimates_amount_']").fill_in with: "20"
      click_on "Submit Request"
      expect(TravelRequest.last.event_title).to match(/Event/)
    end
  end

  scenario "I can submit a travel request" do
    visit "/travel_requests/new"

    find("#travel_request_participation option[value='other']").select_option
    fill_in "displayInput", with: "Super Event's Are Us"

    fill_in "travel_request_event_requests_attributes_0_event_dates", with: "10/1/2019 - 10/3/2019"
    fill_in "travel_request_travel_dates", with: "10/1/2019 - 10/3/2019"

    fill_in "travel_request_event_requests_attributes_0_location", with: "A Place To Be"
    fill_in "travel_request_purpose", with: "A grand purpose"
    fill_in "travel_request_notes_content", with: "Elephants Love Balloons"

    find("select[id^='travel_request_estimates_cost_type_'] option[value='air']").select_option
    find("input[id^='travel_request_estimates_recurrence_']").fill_in with: "2"
    find("input[id^='travel_request_estimates_amount_']").fill_in with: "20"
    expect(page).to have_content "40.00"

    click_on "add-expense-button"

    all("select[id^='travel_request_estimates_cost_type_'] option[value='lodging']")[1].select_option
    all("input[id^='travel_request_estimates_recurrence_']")[1].fill_in with: "3"
    all("input[id^='travel_request_estimates_amount_']")[1].fill_in with: "30"
    expect(page).to have_content "130.00"
    Percy.snapshot(page, name: "Travel Request - New", widths: [375, 768, 1440])
    click_on "Submit Request"

    expect(page).to have_content "Super Event's Are Us 2019, A Place To Be (10/01/2019 to 10/03/2019)"
    expect(page).to have_content "Airfare 2 20.00 40.00\nLodging (per night) 3 30.00 90.00\nTotal: 130.00"
    expect(page).to have_content "Pending"
    expect(page).to have_content "Elephants Love Balloons"

    click_on "Edit"
    expect(page).to have_content "Elephants Love Balloons"
    page.go_back

    click_on "Comment"
    fill_in "travel_request_notes_content", with: "Snakes Love Balloons too!"
    click_on "Comment"

    expect(page).to have_content "Snakes Love Balloons too!"

    click_on "Cancel"
    expect(page).to have_content "Super Event's Are Us 2019, A Place To Be (10/01/2019 to 10/03/2019)"
    expect(page).to have_content "Airfare 2 20.00 40.00\nLodging (per night) 3 30.00 90.00\nTotal: 130.00"
    expect(page).to have_content "Canceled"
    expect(page).not_to have_selector(:link_or_button, "Edit")
    expect(page).not_to have_selector(:link_or_button, "Cancel")
  end

  scenario "It does not create empty estimates" do
    pending("Fixing validation bug")
    visit "/travel_requests/new"

    find("#travel_request_participation option[value='other']").select_option
    fill_in "displayInput", with: "My event has no expenses!"

    fill_in "travel_request_event_requests_attributes_0_event_dates", with: "10/1/2019 - 10/3/2019"
    fill_in "travel_request_travel_dates", with: "10/1/2019 - 10/3/2019"

    fill_in "travel_request_event_requests_attributes_0_location", with: "A Place To Be"
    fill_in "travel_request_purpose", with: "A grand purpose"
    select("In-person", from: "Event Format")
    # We are purposely not entering any Anticipated Expenses
    click_on "Submit Request"
    # Expect this to raise a form validation in Javascript without hitting any rails errors
    # It should not create a new TravelRequest or a new Estimate (but I think it is)
  end

  scenario "I get warned when I try to enter an event with a date" do
    visit "/travel_requests/new"
    find("#travel_request_participation option[value='other']").select_option
    fill_in "displayInput", with: "Geometry 360"
    expect(page).to have_content "It looks like you have a date in this field. Please remove."

    fill_in "travel_request_event_requests_attributes_0_event_dates", with: "10/1/2019 - 10/3/2019"
    fill_in "travel_request_travel_dates", with: "10/1/2019 - 10/3/2019"

    fill_in "travel_request_event_requests_attributes_0_location", with: "A Place To Be"
    fill_in "travel_request_purpose", with: "A grand purpose"
    fill_in "travel_request_notes_content", with: "I like triangles"

    find("select[id^='travel_request_estimates_cost_type_'] option[value='air']").select_option
    find("input[id^='travel_request_estimates_recurrence_']").fill_in with: "2"
    find("input[id^='travel_request_estimates_amount_']").fill_in with: "20"
    expect(page).to have_content "40.00"

    expect(page).not_to have_content "Possible Date Detected"
    click_on "Submit Request"

    expect(page).to have_content "Possible Date Detected"
    click_on "Go Back"

    expect(page).to have_content "New Travel Request"
    click_on "Submit Request"

    expect(page).to have_content "Possible Date Detected"
    click_on "Continue"

    expect(page).to have_content "Geometry 360 2019, A Place To Be (10/01/2019 to 10/03/2019)"
    expect(page).to have_content "Airfare 2 20.00 40.00\nTotal: 40.00"
    expect(page).to have_content "Pending"
    expect(page).to have_content "I like triangles"

    click_on "Edit"
    expect(page).to have_content "I like triangles"
    expect(page).to have_field("displayInput", with: "Geometry 360")
  end
end
