require "rails_helper"

RSpec.describe "events/show", type: :view do
  let(:recurring_event) { RecurringEvent.create! }
  before do
    @event = assign(:event, Event.create!(
                              recurring_event: recurring_event,
                              location: "Location",
                              url: "Url"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Location/)
    expect(rendered).to match(/Url/)
  end
end
