# frozen_string_literal: true
require "rails_helper"

RSpec.feature "New Leave Request", type: :feature, js: true do
  let(:user) { FactoryBot.create :user }
  let(:staff_profile) { FactoryBot.create :staff_profile, :with_department, user: user, given_name: "Sally", surname: "Smith" }

  before do
    sign_in user
    staff_profile
  end

  scenario "I can submit a sick day request" do
    visit "/absence_requests/new"
    find("#absence_request_absence_type option[value='sick']").select_option

    today = Date.parse("2019-10-21")
    tomorrow = Date.parse("2019-10-23")
    js_date_format = "%m/%d/%Y"
    fill_in "absence_request_date", with: "#{today.strftime(js_date_format)} - #{tomorrow.strftime(js_date_format)}"
    Percy.snapshot(page, name: "Leave Request - New", widths: [375, 768, 1440])
    click_on "Apply Changes"

    expect(page).to have_content "Sick Leave"
    expect(page).to have_content "Total Hours Requested\n21.75"
    Percy.snapshot(page, name: "Leave Request - Show", widths: [375, 768, 1440])
  end
end
