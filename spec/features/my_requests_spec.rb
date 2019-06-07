require "rails_helper"

RSpec.feature "My Requests", type: :feature, js: true do
  let(:user) { FactoryBot.create :user }
  let(:staff_profile) { FactoryBot.create :staff_profile, user: user }

  before do
    sign_in user
  end

  scenario "I can filter my requests" do
    FactoryBot.create(:absence_request, creator: staff_profile)
    FactoryBot.create(:absence_request, creator: staff_profile, status: "approved")
    FactoryBot.create(:absence_request, creator: staff_profile, absence_type: "sick")
    FactoryBot.create(:absence_request, creator: staff_profile, absence_type: "sick", status: "approved")
    FactoryBot.create(:travel_request, creator: staff_profile)
    FactoryBot.create(:travel_request, creator: staff_profile, status: "approved")
    FactoryBot.create(:travel_request, creator: staff_profile, status: "approved", travel_category: "professional_development")

    visit "/my_requests"
    assert_selector "article.lux-card", count: Request.count

    select_drop_down(menu: "#status-menu", item: "Approved")
    assert_selector "article.lux-card", count: 4

    select_drop_down(menu: "#request-type-menu", item: "Travel")
    assert_selector "article.lux-card", count: 2

    select_drop_down(menu: "#request-type-menu", item: "Absence")
    assert_selector "article.lux-card", count: 2

    click_link("Status: Approved")
    assert_selector "article.lux-card", count: 4

    click_link("Request type: Absence")
    assert_selector "article.lux-card", count: Request.count

    select_drop_down(menu: "#request-type-menu", item: "Travel")
    assert_selector "article.lux-card", count: 3

    select_drop_down(menu: "#status-menu", item: "Approved")
    assert_selector "article.lux-card", count: 2

    select_drop_down(menu: "#request-type-menu", item: "Professional development")
    assert_selector "article.lux-card", count: 1

    click_link("Status: Approved")
    assert_selector "article.lux-card", count: 1

    select_drop_down(menu: "#request-type-menu", item: "Sick")
    assert_selector "article.lux-card", count: 2

    select_drop_down(menu: "#status-menu", item: "Approved")
    assert_selector "article.lux-card", count: 1
  end

  def select_drop_down(menu:, item:)
    find(menu).click
    within(menu) do
      click_link(item)
    end
  end
end
