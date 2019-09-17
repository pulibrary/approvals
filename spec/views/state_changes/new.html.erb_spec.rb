# frozen_string_literal: true
require "rails_helper"

RSpec.describe "state_changes/new", type: :view do
  let(:state_change) { StateChange.new(agent: nil, request: nil, action: "denied") }
  before do
    assign(:state_change, state_change)
  end

  it "renders new state_change form" do
    render

    assert_select "form[action=?][method=?]", state_changes_path, "post" do
      assert_select "input[name=?]", "state_change[agent_id]"

      assert_select "input[name=?]", "state_change[request_id]"

      assert_select "input[name=?][value=?]", "state_change[action]", state_change.action
    end
  end
end
