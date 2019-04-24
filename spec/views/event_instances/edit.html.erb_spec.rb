require "rails_helper"

RSpec.describe "event_instances/edit", type: :view do
  let(:event) { Event.create! }
  before do
    @event_instance = assign(:event_instance, EventInstance.create!(
                                                event: event,
                                                location: "MyString",
                                                url: "MyString"
    ))
  end

  it "renders the edit event_instance form" do
    render

    assert_select "form[action=?][method=?]", event_instance_path(@event_instance), "post" do
      assert_select "input[name=?]", "event_instance[event_id]"

      assert_select "input[name=?]", "event_instance[location]"

      assert_select "input[name=?]", "event_instance[url]"
    end
  end
end
