# frozen_string_literal: true
require "rails_helper"

RSpec.feature "New Leave Request", type: :feature, js: true do
  let(:user) { FactoryBot.create :user }
  let(:staff_profile) do
    FactoryBot.create :staff_profile, :with_department, user: user, given_name: "Sally", surname: "Smith",
                                                        vacation_balance: 90.1, personal_balance: 16.0, sick_balance: 100.0
  end

  before do
    sign_in user
    staff_profile
  end

  scenario "I can submit a travel request" do
    visit "/travel_requests/new"

    find("#travel_request_participation option[value='other']").select_option
    fill_in "displayInput", with: "Super Event"

    today = Date.parse("2019-10-21")
    tomorrow = Date.parse("2019-10-23")
    js_date_format = "%m/%d/%Y"
    fill_in "travel_request_event_requests_attributes_0_event_dates", with: "#{today.strftime(js_date_format)} - #{tomorrow.strftime(js_date_format)}"
    fill_in "travel_request_travel_dates", with: "#{today.strftime(js_date_format)} - #{tomorrow.strftime(js_date_format)}"

    fill_in "travel_request_event_requests_attributes_0_location", with: "A Place To Be"
    fill_in "travel_request_purpose", with: "A grand purpose"

    click_on "add-expense-button"

    find("#travel_request_estimates_cost_type option[value='air']").select_option
    fill_in "travel_request_estimates_recurrence", with: "2"
    fill_in "travel_request_estimates_amount", with: "20"
    expect(page).to have_content "40.00"

    click_on "add-expense-button"

    all("#travel_request_estimates_cost_type option[value='lodging']")[1].select_option
    all("#travel_request_estimates_recurrence")[1].fill_in with: "3"
    all("#travel_request_estimates_amount")[1].fill_in with: "30"
    expect(page).to have_content "130.00"
    Percy.snapshot(page, name: "Travel Request - New", widths: [375, 768, 1440])
    click_on "Apply Changes"

    # TODO: the date chooser is not setting the dates correctly.  It is choosing the day before the date sent in
    expect(page).to have_content "Super Event 2019, A Place To Be (10/21/2019 to 10/23/2019)"
    expect(page).to have_content "air 2 20.00 40.00\nlodging 3 30.00 90.00\nTotal 130.00"
  end
end
