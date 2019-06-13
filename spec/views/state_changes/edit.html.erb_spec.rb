# frozen_string_literal: true
require "rails_helper"

RSpec.describe "state_changes/edit", type: :view do
  let(:state_change) { FactoryBot.create(:state_change) }
  before do
    assign(:state_change, state_change)
  end

  it "renders the edit state_change form" do
    render

    assert_select "form[action=?][method=?]", state_change_path(state_change), "post" do
      assert_select "input[name=?][value=?]", "state_change[approver_id]", state_change.approver_id.to_s

      assert_select "input[name=?][value=?]", "state_change[request_id]", state_change.request_id.to_s

      assert_select "input[name=?][value=?]", "state_change[action]", state_change.action.to_s
    end
  end
end
