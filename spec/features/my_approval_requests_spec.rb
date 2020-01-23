# frozen_string_literal: true
require "rails_helper"

RSpec.feature "My Approval Requests", type: :feature, js: true do
  let(:user) { FactoryBot.create :user }
  let(:staff_profile) { FactoryBot.create :staff_profile, :with_department, :with_supervisor, user: user }
  let(:employee_user) { FactoryBot.create :user, uid: "jdoe" }
  let(:employee) { FactoryBot.create :staff_profile, supervisor: staff_profile, department: staff_profile.department, given_name: "Jane", surname: "Doe", user: employee_user }

  before do
    sign_in user
  end

  scenario "I can filter my requests" do
    FactoryBot.create(:absence_request, creator: employee, start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"))
    # sick_leave = FactoryBot.create(:absence_request, creator: employee, absence_type: "sick", start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"))
    FactoryBot.create(:absence_request, creator: employee, absence_type: "sick", start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"))
    recurring_event = FactoryBot.create(:recurring_event, name: "Awesome Event", description: "The most awesome event!!!")
    event_request = FactoryBot.build(:event_request, recurring_event: recurring_event, start_date: Date.parse("2019-10-21"), end_date: Date.parse("2019-10-23"))
    FactoryBot.create(:travel_request, creator: employee,
                                       start_date: Date.parse("2019-10-21"),
                                       end_date: Date.parse("2019-10-23"),
                                       event_requests: [event_request])

    visit "/my_approval_requests"
    Percy.snapshot(page, name: "My Approval Requests - Show", widths: [375, 768, 1440])
    assert_selector ".my-request .lux-card", count: Request.count

    select_drop_down(menu: "#request-type-menu", item: "Travel")
    assert_selector ".my-request .lux-card", count: 1
    assert_selector "a", text: "Doe, Jane (jdoe) - Awesome Event 2019, Location"

    # select_drop_down(menu: "#request-type-menu", item: "Absence")
    # assert_selector ".my-request .lux-card", count: 2
    # assert_selector "a", text: "Doe, Jane (jdoe) - Sick"

    # click_link("Request type: Absence")
    # assert_selector ".my-request .lux-card", count: Request.count

    # click_link "Doe, Jane (jdoe) - Sick"
    # assert_selector "h1", text: "Review Leave Request"
    # click_on "Approve"
    # expect(sick_leave.reload).to be_approved
  end

  scenario "I can search my requests" do
    absence_request = FactoryBot.create(:absence_request, creator: employee)
    absence_request2 = FactoryBot.create(:absence_request, creator: employee)
    travel_request = FactoryBot.create(:travel_request, creator: employee)
    FactoryBot.create(:note, content: "elephants love balloons", request: absence_request)
    FactoryBot.create(:note, content: "flamingoes are pink because of shrimp", request: absence_request2)
    FactoryBot.create(:note, content: "elephants love balloons", request: travel_request)
    visit "/my_approval_requests"

    # filter with out query
    # select_drop_down(menu: "#request-type-menu", item: "Absence")
    # assert_selector ".my-request .lux-card", count: 2
    # ids = page.all(:css, ".my-request .lux-card").map { |element| element["id"].to_i }
    # expect(ids).to contain_exactly absence_request.id, absence_request2.id

    # search query clears the filter
    fill_in "query", with: "balloons"
    click_button "search"

    expect(find("#query").value).to eq "balloons"
    assert_selector ".my-request .lux-card", count: 2
    ids = page.all(:css, ".my-request .lux-card").map { |element| element["id"].to_i }
    expect(ids).to contain_exactly absence_request.id, travel_request.id

    # filter with query
    select_drop_down(menu: "#request-type-menu", item: "Travel")
    expect(find("#query").value).to eq "balloons"
    assert_selector ".my-request .lux-card", count: 1
    ids = page.all(:css, ".my-request .lux-card").map { |element| element["id"].to_i }
    expect(ids).to contain_exactly travel_request.id

    # clear the filter
    click_link("Request type: Travel")

    # clearing cilter retains search results
    expect(find("#query").value).to eq "balloons"
    assert_selector ".my-request .lux-card", count: 2
    ids = page.all(:css, ".my-request .lux-card").map { |element| element["id"].to_i }
    expect(ids).to contain_exactly absence_request.id, travel_request.id
  end

  def select_drop_down(menu:, item:)
    find(menu).click
    within(menu) do
      click_link(item)
    end
  end
end
