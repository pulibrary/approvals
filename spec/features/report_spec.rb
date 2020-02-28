# frozen_string_literal: true
require "rails_helper"

RSpec.feature "My Requests", type: :feature, js: true do
  let(:user) { FactoryBot.create :user }
  let(:staff_profile) { FactoryBot.create :staff_profile, :with_department, :with_supervisor, user: user }

  before do
    sign_in user
  end

  scenario "I can filter reports" do
    direct_report = FactoryBot.create :staff_profile, supervisor: staff_profile, department: staff_profile.department
    FactoryBot.create(:absence_request, creator: staff_profile.supervisor, start_date: Date.parse("2019-10-12"), end_date: Date.parse("2019-10-13"))
    FactoryBot.create(:absence_request, creator: staff_profile, start_date: Date.parse("2019-10-12"), end_date: Date.parse("2019-10-13"))
    FactoryBot.create(:absence_request, creator: direct_report, action: "approve", start_date: Date.parse("2019-10-13"), end_date: Date.parse("2019-10-14"))
    FactoryBot.create(:absence_request, creator: staff_profile, absence_type: "sick", start_date: Date.parse("2019-10-14"), end_date: Date.parse("2019-10-15"))
    FactoryBot.create(:absence_request, creator: staff_profile, absence_type: "sick", action: "approve", start_date: Date.parse("2019-10-15"), end_date: Date.parse("2019-10-16"))
    recurring_event = FactoryBot.create(:recurring_event, name: "Awesome Event", description: "The most awesome event!!!")
    event_request = FactoryBot.build(:event_request, recurring_event: recurring_event, start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"))
    FactoryBot.create(:travel_request, creator: staff_profile, start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"), event_requests: [event_request])
    recurring_event2 = FactoryBot.create(:recurring_event, name: "Best Event Ever", description: "The best event we could ever go to!!!")
    event_request2 = FactoryBot.build(:event_request, recurring_event: recurring_event2, start_date: Date.parse("2020-10-21"), end_date: Date.parse("2020-10-23"))
    FactoryBot.create(:travel_request, creator: staff_profile, action: "approve", start_date: Date.parse("2020-10-20"), end_date: Date.parse("2012-10-23"), event_requests: [event_request2])
    recurring_event3 = FactoryBot.create(:recurring_event, name: "Wow", description: "Wow you must go!!!")
    event_request3 = FactoryBot.build(:event_request, recurring_event: recurring_event3, start_date: Date.parse("2020-05-21"), end_date: Date.parse("2020-05-23"))
    FactoryBot.create(:travel_request, creator: staff_profile, action: "approve",
                                       travel_category: "professional_development", start_date: Date.parse("2020-05-21"), end_date: Date.parse("2020-05-23"), event_requests: [event_request3])

    visit "/reports"

    Percy.snapshot(page, name: "Reports - show", widths: [375, 768, 1440])
    assert_selector ".my-request tr", count: Request.count # header row included in count

    select_drop_down(menu: "#status-menu", item: "Approved")
    assert_selector ".my-request tr", count: 5 # header row included in count

    select_drop_down(menu: "#request-type-menu", item: "Travel")
    assert_selector ".my-request tr", count: 3 # header row included in count

    click_link("Status: Approved")
    assert_selector ".my-request tr", count: 4

    fill_in "dateRange", with: "10/10/2019 - 10/25/2019"
    click_on "Filter by Date"
    assert_selector ".my-request tr", count: 2
  end

  def select_drop_down(menu:, item:)
    find(menu).click
    within(menu) do
      click_link(item)
    end
  end
end
