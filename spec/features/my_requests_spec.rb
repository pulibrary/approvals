require "rails_helper"

RSpec.feature "My Requests", type: :feature do
  let(:user) { FactoryBot.create :user }
  let(:staff_profile) { FactoryBot.create :staff_profile, user: user }

  before do
    sign_in user
  end

  scenario "I can filter my requests" do
    FactoryBot.create(:absence_request, creator: staff_profile)
    FactoryBot.create(:absence_request, creator: staff_profile, status: 'approved')
    FactoryBot.create(:travel_request, creator: staff_profile)
    FactoryBot.create(:travel_request, creator: staff_profile, status: 'approved')

    visit "/my_requests"
    assert_selector "card", count: 4

    click_link("Approved")
    assert_selector "card", count: 2

    click_link("Travel")
    assert_selector "card", count: 1

    click_link("Clear Filters")
    assert_selector "card", count: 4
  end
end
