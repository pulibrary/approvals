require "rails_helper"

RSpec.describe "event_requests/show", type: :view do
  let(:recurring_event) { RecurringEvent.create! }
  let(:staff_profile) { FactoryBot.create(:staff_profile) }
  before do
    @event_request = assign(:event_request, EventRequest.create!(
                                              recurring_event: recurring_event,
                                              location: "Location",
                                              url: "Url",
                                              request: Request.create!(creator: staff_profile)
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Location/)
    expect(rendered).to match(/Url/)
  end
end
