require "rails_helper"

RSpec.describe "events/show", type: :view do
  before do
    @event = assign(:event, Event.create!(
                              name: "Name",
                              description: "MyText",
                              url: "Url"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Url/)
  end
end
