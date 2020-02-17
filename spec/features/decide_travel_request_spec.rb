# frozen_string_literal: true
require "rails_helper"

RSpec.feature "New Leave Request", type: :feature, js: true do
  let(:user) { FactoryBot.create :user }
  let(:department_head) do
    profile = FactoryBot.create :staff_profile, user: user, given_name: "Sally", surname: "Smith"
    FactoryBot.create :department, head: profile
    profile
  end
  let(:staff_profile) do
    FactoryBot.create :staff_profile, department: department_head.department, given_name: "John", surname: "Doe",
                                      supervisor: department_head
  end

  let(:travel_request) { FactoryBot.create :travel_request, creator: staff_profile }

  before do
    sign_in user
  end

  scenario "I can approve a travel request" do
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
    find("#travel_request_travel_category option[value='business']").select_option
    click_on "Approve"
    expect(page).to have_content "Travel request was successfully updated."
    expect(page).to have_content "Approved"
    expect(page).to have_content "Elephants Love Balloons"
  end
end
