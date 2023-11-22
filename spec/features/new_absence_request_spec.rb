# frozen_string_literal: true
require "rails_helper"

RSpec.feature "New Absence Request", type: :feature, js: true do
  let(:user) { FactoryBot.create :user }
  let(:staff_profile) do
    FactoryBot.create :staff_profile, :with_department, user: user, given_name: "Sally", surname: "Smith",
                                                        vacation_balance: 90.1, personal_balance: 16.0, sick_balance: 100.0
  end

  before do
    sign_in user
    staff_profile
    Timecop.freeze(Time.utc(2022))
  end

  after do
    Timecop.return
  end

  scenario "I can submit a sick day request and cancel it" do
    visit "/"
    click_on "New absence request"
    expect(page).to have_content "New Absence Request"
    expect(page).to have_content "Balances as of the end of your last pay period"
    expect(page).to have_content "Vacation\n90.1 Hours"
    expect(page).to have_content "Sick\n100.0 Hours"
    expect(page).to have_content "Personal\n16.0 Hours"
    expect(page).to have_content "7.25 hours = 1.00 days (0 holiday and weekend dates excluded.)"

    find("#absence_request_absence_type option[value='sick']").select_option

    today = Date.parse("2019-10-21")
    tomorrow = Date.parse("2019-10-23")
    js_date_format = "%m/%d/%Y"
    fill_in "absence_request_date", with: "#{today.strftime(js_date_format)} - #{tomorrow.strftime(js_date_format)}"
    page.percy_snapshot("Leave Request - New", widths: [375, 768, 1440])
    click_on "Submit Request"

    expect(page).to have_content "Sick Leave"
    expect(page).to have_content "Total Hours\n21.75"
    expect(page).to have_content "Pending"
    page.percy_snapshot("Leave Request - Show", widths: [375, 768, 1440])

    # Approve in the background
    Request.last.approve!(agent: staff_profile.supervisor)
    page.refresh
    expect(page).to have_content "Sick Leave"
    expect(page).to have_content "Total Hours\n21.75"
    expect(page).to have_content "Approved"

    click_on "Mark as Recorded"

    expect(page).to have_content "Sick Leave"
    expect(page).to have_content "Total Hours\n21.75"
    expect(page).to have_content "Recorded"

    click_on "Comment"
    fill_in "absence_request_notes_content", with: "Snakes Love Balloons too!"
    click_on "Comment"

    expect(page).to have_content "Snakes Love Balloons too!"

    click_on "Cancel"
    expect(page).to have_content "Sick Leave"
    expect(page).to have_content "Total Hours\n21.75"
    expect(page).to have_content "Canceled"
    expect(page).not_to have_selector(:link_or_button, "Edit")
    expect(page).not_to have_selector(:link_or_button, "Cancel")
  end
end
