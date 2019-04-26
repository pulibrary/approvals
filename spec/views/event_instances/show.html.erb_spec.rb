require "rails_helper"

RSpec.describe "event_instances/show", type: :view do
  let(:recurring_event) { RecurringEvent.create! }
  before do
    @event_instance = assign(:event_instance, EventInstance.create!(
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
