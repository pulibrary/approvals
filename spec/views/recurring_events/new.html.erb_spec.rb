# frozen_string_literal: true
require "rails_helper"

RSpec.describe "recurring_events/new", type: :view do
  let(:recurring_event) do
    FactoryBot.build(
      :recurring_event,
      name: "event name",
      description: "event description",
      url: "event url"
    )
  end
  before do
    assign(:recurring_event, recurring_event)
  end

  it "renders new recurring_event form" do
    render

    assert_select "form[action=?][method=?]", recurring_events_path, "post" do
      assert_select "input[name=?][value=?]", "recurring_event[name]", recurring_event.name

      assert_select "textarea[name=?]", "recurring_event[description]", text: recurring_event.description

      assert_select "input[name=?][value=?]", "recurring_event[url]", recurring_event.url
    end
  end
end
