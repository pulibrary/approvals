# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Delegate", type: :feature, js: true do
  let(:user) { FactoryBot.create :user }
  let(:staff_profile) { FactoryBot.create :staff_profile, :with_department, :with_supervisor, given_name: "Sally", user: user }
  let(:delegate_user) { FactoryBot.create :user }
  let(:delegate_staff_profile) { FactoryBot.create :staff_profile, :with_department, :with_supervisor, given_name: "Joe", surname: "Schmo", user: delegate_user }
  let(:delegate) { FactoryBot.create :delegate, delegator: delegate_staff_profile, delegate: staff_profile }

  before do
    sign_in user
  end

  scenario "I can see my requests and my delegates" do
    FactoryBot.create(:absence_request, creator: staff_profile, start_date: Date.parse("2019-10-12"), end_date: Date.parse("2019-10-13"))
    FactoryBot.create(:absence_request, creator: delegate_staff_profile, start_date: Date.parse("2019-10-12"), end_date: Date.parse("2019-10-13"))
    FactoryBot.create(:absence_request, creator: delegate_staff_profile, start_date: Date.parse("2019-09-12"), end_date: Date.parse("2019-09-13"))

    visit "/my_requests"
    assert_selector ".my-request .lux-card", count: 1

    # Todo we really should not need to hand jam the url
    visit assume_delegate_path(delegate)

    assert_selector "div.lux-alert", text: "You are acting on behalf of #{delegate_staff_profile}"
    assert_selector ".my-request .lux-card", count: 2

    click_link "New leave request"
    assert_selector "div.lux-alert", text: "You are acting on behalf of #{delegate_staff_profile}"
    find("#absence_request_absence_type option[value='sick']").select_option
    today = Date.parse("2019-10-21")
    tomorrow = Date.parse("2019-10-23")
    js_date_format = "%m/%d/%Y"
    fill_in "absence_request_date", with: "#{today.strftime(js_date_format)} - #{tomorrow.strftime(js_date_format)}"
    click_on "Submit Request"
    expect(page).to have_content "Joe Schmo\nSick Leave (#{today.strftime(js_date_format)} to #{tomorrow.strftime(js_date_format)})"

    click_link "My Requests"
    assert_selector "div.lux-alert", text: "You are acting on behalf of #{delegate_staff_profile}"
    assert_selector ".my-request .lux-card", count: 3

    # Todo we really should not need to hand jam the url
    visit cancel_delegates_path

    assert_selector "div.lux-alert", text: "You are now acting on your own behalf"
    assert_selector ".my-request .lux-card", count: 1
  end
end
