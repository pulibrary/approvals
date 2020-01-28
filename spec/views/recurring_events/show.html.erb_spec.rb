# frozen_string_literal: true
require "rails_helper"

RSpec.describe "recurring_events/show", type: :view do
  before do
    @recurring_event = assign(:recurring_event, FactoryBot.create(
                                                  :recurring_event,
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
