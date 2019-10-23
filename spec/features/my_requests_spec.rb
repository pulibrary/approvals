# frozen_string_literal: true
require "rails_helper"

RSpec.feature "My Requests", type: :feature, js: true do
  let(:user) { FactoryBot.create :user }
  let(:staff_profile) { FactoryBot.create :staff_profile, :with_department, :with_supervisor, user: user }

  before do
    sign_in user
  end

  scenario "I can filter my requests" do
    FactoryBot.create(:absence_request, creator: staff_profile, start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"))
    FactoryBot.create(:absence_request, creator: staff_profile, action: "approve", start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"))
    FactoryBot.create(:absence_request, creator: staff_profile, absence_type: "sick", start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"))
    FactoryBot.create(:absence_request, creator: staff_profile, absence_type: "sick", action: "approve", start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"))
    FactoryBot.create(:travel_request, creator: staff_profile, start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"))
    FactoryBot.create(:travel_request, creator: staff_profile, action: "approve", start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"))
    FactoryBot.create(:travel_request, creator: staff_profile, action: "approve", travel_category: "professional_development", start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"))

    visit "/my_requests"
    Percy.snapshot(page, name: "My Requests - Show", widths: [375, 768, 1440])
    assert_selector "article.lux-card", count: Request.count

    select_drop_down(menu: "#status-menu", item: "Approved")
    assert_selector "article.lux-card", count: 4

    select_drop_down(menu: "#request-type-menu", item: "Travel")
    assert_selector "article.lux-card", count: 2

    select_drop_down(menu: "#request-type-menu", item: "Absence")
    assert_selector "article.lux-card", count: 2

    # clearing a filter
    click_link("Status: Approved")
    assert_selector "article.lux-card", count: 4

    click_link("Request type: Absence")
    assert_selector "article.lux-card", count: Request.count
  end

  scenario "I can sort my requests" do
    tomorrow_request = FactoryBot.create(:absence_request, creator: staff_profile, start_date: Time.zone.tomorrow)
    yesterday_request = FactoryBot.create(:absence_request, creator: staff_profile, start_date: Time.zone.yesterday)
    today_request = FactoryBot.create(:travel_request, creator: staff_profile, start_date: Time.zone.today)

    visit "/my_requests"
    expect(find("#sort-menu").text).to start_with "Sort: Start date - descending"
    ids = page.all(:css, "article.lux-card").map { |element| element["id"].to_i }
    expect(ids).to eq([tomorrow_request, today_request, yesterday_request].map(&:id))

    select_drop_down(menu: "#sort-menu", item: "Start date - ascending")
    expect(find("#sort-menu").text).to start_with "Sort: Start date - ascending"
    ids = page.all(:css, "article.lux-card").map { |element| element["id"].to_i }
    expect(ids).to eq([yesterday_request, today_request, tomorrow_request].map(&:id))

    select_drop_down(menu: "#sort-menu", item: "Date created - descending")
    expect(find("#sort-menu").text).to start_with "Sort: Date created - descending"

    select_drop_down(menu: "#sort-menu", item: "Date created - ascending")
    expect(find("#sort-menu").text).to start_with "Sort: Date created - ascending"

    select_drop_down(menu: "#sort-menu", item: "Date modified - descending")
    expect(find("#sort-menu").text).to start_with "Sort: Date modified - descending"

    select_drop_down(menu: "#sort-menu", item: "Date modified - ascending")
    expect(find("#sort-menu").text).to start_with "Sort: Date modified - ascending"
  end

  scenario "I can search my requests" do
    absence_request = FactoryBot.create(:absence_request, creator: staff_profile, action: :approve)
    absence_request2 = FactoryBot.create(:absence_request, creator: staff_profile, action: :deny)
    travel_request = FactoryBot.create(:travel_request, creator: staff_profile, action: :approve)
    FactoryBot.create(:note, content: "elephants love balloons", request: absence_request)
    FactoryBot.create(:note, content: "elephants love balloons", request: absence_request2)
    FactoryBot.create(:note, content: "flamingoes are pink because of shrimp", request: travel_request)
    visit "/my_requests"

    # filter with no search query
    select_drop_down(menu: "#status-menu", item: "Approved")
    assert_selector "article.lux-card", count: 2

    # search query clears the filter
    fill_in "query", with: "balloons"
    click_button "search"

    expect(find("#query").value).to eq "balloons"
    assert_selector "article.lux-card", count: 2
    ids = page.all(:css, "article.lux-card").map { |element| element["id"].to_i }
    expect(ids).to contain_exactly absence_request.id, absence_request2.id

    # filtering on a search result retains search results
    select_drop_down(menu: "#status-menu", item: "Approved")
    assert_selector "article.lux-card", count: 1
  end

  scenario "I can get to the page to add a new absence request" do
    staff_profile

    visit "/my_requests"

    click_link("New leave request")
    expect(page).to have_content "New Leave Request"
  end

  def select_drop_down(menu:, item:)
    find(menu).click
    within(menu) do
      click_link(item)
    end
  end
end
