# frozen_string_literal: true

require "rails_helper"

RSpec.describe "My Requests", type: :feature, js: true do
  let(:user) { create(:user) }
  let(:staff_profile) { create(:staff_profile, :with_department, :with_supervisor, user:) }

  before do
    sign_in user
  end
  # Re-enable this test after https://github.com/pulibrary/lux-design-system/issues/348 is completed and added to Approvals

  xit "I can filter my requests" do
    Timecop.freeze(Time.utc(2022))

    create(:absence_request, creator: staff_profile, start_date: Date.parse("2019-10-12"),
                             end_date: Date.parse("2019-10-13"))
    create(:absence_request, creator: staff_profile, action: "approve",
                             start_date: Date.parse("2019-10-13"), end_date: Date.parse("2019-10-14"))
    create(:absence_request, creator: staff_profile, absence_type: "sick",
                             start_date: Date.parse("2019-10-14"), end_date: Date.parse("2019-10-15"))
    create(:absence_request, creator: staff_profile, absence_type: "sick", action: "approve",
                             start_date: Date.parse("2019-10-15"), end_date: Date.parse("2019-10-16"))
    recurring_event = create(:recurring_event, name: "Awesome Event",
                                               description: "The most awesome event!!!")
    event_request = build(:event_request, recurring_event:,
                                          start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"))
    create(:travel_request, creator: staff_profile, start_date: Date.parse("2019-10-21"),
                            end_date: Date.parse("2019-10-23"), event_requests: [event_request])
    recurring_event2 = create(:recurring_event, name: "Best Event Ever",
                                                description: "The best event we could ever go to!!!")
    event_request2 = build(:event_request, recurring_event: recurring_event2,
                                           start_date: Date.parse("2020-10-21"), end_date: Date.parse("2020-10-23"))
    create(:travel_request, creator: staff_profile, action: "approve", start_date: Date.parse("2020-10-20"),
                            end_date: Date.parse("2012-10-23"), event_requests: [event_request2])
    recurring_event3 = create(:recurring_event, name: "Wow", description: "Wow you must go!!!")
    event_request3 = build(:event_request, recurring_event: recurring_event3,
                                           start_date: Date.parse("2020-05-21"), end_date: Date.parse("2020-05-23"))
    create(:travel_request, creator: staff_profile, action: "approve",
                            travel_category: "professional_development", start_date: Date.parse("2020-05-21"), end_date: Date.parse("2020-05-23"), event_requests: [event_request3])

    visit "/my_requests"
    assert_selector ".my-request .lux-card", count: Request.count

    select_drop_down(menu: "#status-menu", item: "Approved")
    assert_selector ".my-request .lux-card", count: 4

    select_drop_down(menu: "#request-type-menu", item: "Travel")
    assert_selector ".my-request .lux-card", count: 2

    select_drop_down(menu: "#request-type-menu", item: "Absence")
    assert_selector ".my-request .lux-card", count: 2
    expect(page).to have_content("Vacation (8.0)")
    expect(page).to have_content("Sick Leave (8.0)")

    # clearing a filter
    click_link("Status: Approved")
    assert_selector ".my-request .lux-card", count: 4

    click_link("Request type: Absence")
    assert_selector ".my-request .lux-card", count: Request.count

    Timecop.return
  end
  # Re-enable this test after https://github.com/pulibrary/lux-design-system/issues/348 is completed and added to Approvals

  xit "I can sort my requests" do
    yesterday_request = create(:absence_request, creator: staff_profile, start_date: Time.zone.yesterday)
    today_request = create(:travel_request, creator: staff_profile, start_date: Time.zone.today)
    tomorrow_request = create(:absence_request, creator: staff_profile, start_date: Time.zone.tomorrow)

    visit "/my_requests"

    expect(page).to have_content("My Requests")
    expect(find("#sort-menu").text).to start_with "Sort: Date modified - descending"
    ids = page.all(:css, ".my-request .lux-card").map { |element| element["id"].to_i }
    expect(ids).to eq([tomorrow_request, today_request, yesterday_request].map(&:id))

    select_drop_down(menu: "#sort-menu", item: "Start date - ascending")
    expect(find("#sort-menu").text).to start_with "Sort: Start date - ascending"
    ids = page.all(:css, ".my-request .lux-card").map { |element| element["id"].to_i }
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

  it "I can search my requests" do
    absence_request = create(:absence_request, creator: staff_profile, action: :approve)
    absence_request2 = create(:absence_request, creator: staff_profile, action: :deny)
    travel_request = create(:travel_request, creator: staff_profile, action: :approve)
    create(:note, content: "elephants love balloons", request: absence_request)
    create(:note, content: "elephants love balloons", request: absence_request2)
    create(:note, content: "flamingoes are pink because of shrimp", request: travel_request)
    visit "/my_requests"

    # filter with no search query
    select_drop_down(menu: "#status-menu", item: "Approved")
    assert_selector ".my-request .lux-card", count: 2

    # search query clears the filter
    fill_in "query", with: "balloons"
    click_button "search"

    expect(find("#query").value).to eq "balloons"
    assert_selector ".my-request .lux-card", count: 2
    ids = page.all(:css, ".my-request .lux-card").map { |element| element["id"].to_i }
    expect(ids).to contain_exactly absence_request.id, absence_request2.id

    # filtering on a search result retains search results
    select_drop_down(menu: "#status-menu", item: "Approved")
    assert_selector ".my-request .lux-card", count: 1

    # the user should be informed of no results
    fill_in "query", with: "adfadfsd"
    click_button "search"

    expect(find("#query").value).to eq "adfadfsd"
    expect(page).to have_css("#no-results")
  end

  def select_drop_down(menu:, item:)
    find(menu).click
    within(menu) do
      click_link(item)
    end
  end
end
