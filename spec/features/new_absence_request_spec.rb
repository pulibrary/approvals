# frozen_string_literal: true
require "rails_helper"

RSpec.feature "New Leave Request", type: :feature, js: true do
  let(:user) { FactoryBot.create :user }
  let(:staff_profile) { FactoryBot.create :staff_profile, user: user }

  before do
    sign_in user
  end

  scenario "I can submit a sick day request" do
    visit "/absence_requests/new"
    find("#absence_request_absence_type option[value='sick']").select_option

    date_format = "%m/%d/%Y"
    today_str = Time.zone.today.strftime(date_format)
    tomorrow_str = Time.zone.tomorrow.strftime(date_format)
    fill_in "absence_request_start_date", with: today_str
    fill_in "absence_request_end_date", with: tomorrow_str
    expect(find("#absence_request_start_time").value).to eq "8:45 AM"
    expect(find("#absence_request_end_time").value).to eq "5:00 PM"
    find("#absence_request_start_time option[value='12:00 PM']").select_option
    find("#absence_request_end_time option[value='5:00 PM']").select_option
    # fill_in "comment", with: "i am sick."
  end
end
