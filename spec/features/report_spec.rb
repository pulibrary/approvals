# frozen_string_literal: true
require "rails_helper"

RSpec.feature "My Requests", type: :feature, js: true do
  let(:user) { FactoryBot.create :user }
  let(:department) { FactoryBot.create :department, :with_head, name: "ITIMS" }
  let(:staff_profile) { FactoryBot.create :staff_profile, :with_supervisor, department: department, user: user, given_name: "Pat", surname: "Doe" }

  before do
    sign_in user
  end

  after do
    Timecop.return
  end

  # Re-enable this test after https://github.com/pulibrary/lux-design-system/issues/348 is completed and added to Approvals
  xscenario "I can filter reports" do
    Timecop.freeze(Time.utc(2019, "oct", 20))

    direct_report = FactoryBot.create :staff_profile, supervisor: staff_profile, department: staff_profile.department, given_name: "Sally", surname: "Smith"
    FactoryBot.create(:absence_request, creator: staff_profile.supervisor, start_date: Date.parse("2019-10-12"), end_date: Date.parse("2019-10-13"))
    FactoryBot.create(:absence_request, creator: staff_profile, start_date: Date.parse("2019-10-12"), end_date: Date.parse("2019-10-13"), hours_requested: 10.3)
    FactoryBot.create(:absence_request, creator: direct_report, action: "approve", start_date: Date.parse("2019-10-13"), end_date: Date.parse("2019-10-14"), hours_requested: 15.5)
    FactoryBot.create(:absence_request, creator: staff_profile, absence_type: "sick", start_date: Date.parse("2019-10-14"), end_date: Date.parse("2019-10-15"), hours_requested: 10)
    FactoryBot.create(:absence_request, creator: staff_profile, absence_type: "sick", action: "approve", start_date: Date.parse("2019-10-15"),
                                        end_date: Date.parse("2019-10-16"), hours_requested: 17.3)
    recurring_event = FactoryBot.create(:recurring_event, name: "Awesome Event", description: "The most awesome event!!!")
    event_request = FactoryBot.build(:event_request, recurring_event: recurring_event, start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"))
    FactoryBot.create(:travel_request, creator: staff_profile, start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"), event_requests: [event_request])
    recurring_event2 = FactoryBot.create(:recurring_event, name: "Best Event Ever", description: "The best event we could ever go to!!!")
    event_request2 = FactoryBot.build(:event_request, recurring_event: recurring_event2, start_date: Date.parse("2020-10-21"), end_date: Date.parse("2020-10-23"))
    FactoryBot.create(:travel_request, creator: staff_profile, action: "approve", start_date: Date.parse("2020-10-20"), end_date: Date.parse("2020-10-23"), event_requests: [event_request2])
    recurring_event3 = FactoryBot.create(:recurring_event, name: "Wow", description: "Wow you must go!!!")
    event_request3 = FactoryBot.build(:event_request, recurring_event: recurring_event3, start_date: Date.parse("2020-05-21"), end_date: Date.parse("2020-05-23"))
    FactoryBot.create(:travel_request, :with_note_and_estimate, creator: staff_profile, action: "approve",
                                                                travel_category: "professional_development", start_date: Date.parse("2020-05-21"),
                                                                end_date: Date.parse("2020-05-23"), event_requests: [event_request3])

    visit "/"

    click_on "Requests"
    click_on "Reports"

    assert_selector ".my-request tr", count: Request.count # header row included in count
    expect(page).to have_content "Wow 2020, Location (05/21/2020 to 05/23/2020) May 21, 2020 May 23, 2020 Approved Pat Doe ITIMS In-person October 20, 2019 150.00"
    expect(page).to have_content "Best Event Ever 2020, Location (10/21/2020 to 10/23/2020) October 20, 2020 October 23, 2020 Approved Pat Doe ITIMS"
    expect(page).to have_content "Awesome Event 2019, Location (10/21/2019 to 10/23/2019) October 21, 2019 October 23, 2019 Pending Pat Doe ITIMS In-person 0.00\n"
    expect(page).to have_content "Sick Leave (17.3 hours) October 15, 2019 October 16, 2019 Approved Pat Doe ITIMS October 20, 2019"
    expect(page).to have_content "Sick Leave (10.0 hours) October 14, 2019 October 15, 2019 Pending Pat Doe ITIMS"
    expect(page).to have_content "Vacation (15.5 hours) October 13, 2019 October 14, 2019 Approved Sally Smith ITIMS October 20, 2019"
    expect(page).to have_content "Vacation (10.3 hours) October 12, 2019 October 13, 2019 Pending Pat Doe ITIMS"

    click_on "Status"
    click_on "Approved"
    assert_selector ".my-request tr", count: 5 # header row included in count
    click_on "Request type"
    click_on "Travel"
    assert_selector ".my-request tr", count: 3 # header row included in count

    click_link("Status: Approved")
    assert_selector ".my-request tr", count: 4
    # The date range is not currently actually being filled in
    # You can verify this by turning off "headless" mode and running the test with a byebug after the next line
    fill_in "dateRange", with: "10/10/2019 - 10/25/2019"
    click_on "Filter by Date"
    assert_selector ".my-request tr", count: 2

    click_link("Request type: Travel")
    assert_selector ".my-request tr", count: 6 # header row included in count

    select_drop_down(menu: "#request-type-menu", item: "Absence")
    assert_selector ".my-request tr", count: 5 # header row included in count
  end

  def select_drop_down(menu:, item:)
    find(menu).click
    within(menu) do
      click_link(item)
    end
  end
end
