require "rails_helper"

RSpec.describe "event_instances/edit", type: :view do
  before do
    @event_instance = assign(:event_instance, EventInstance.create!(
                                                recurring_event: nil,
                                                location: "MyString",
                                                url: "MyString"
    ))
  end

  it "renders the edit event_instance form" do
    render

    assert_select "form[action=?][method=?]", event_instance_path(@event_instance), "post" do
      assert_select "input[name=?]", "event_instance[recurring_event_id]"

      assert_select "input[name=?]", "event_instance[location]"

      assert_select "input[name=?]", "event_instance[url]"
    end
  end
end
