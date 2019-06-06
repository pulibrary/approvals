require "rails_helper"

RSpec.describe "state_changes/index", type: :view do
  let(:state_change1) { FactoryBot.create(:state_change) }
  let(:state_change2) { FactoryBot.create(:state_change) }
  before do
    assign(:state_changes, [state_change1, state_change2])
  end

  it "renders a list of state_changes" do
    render
    assert_select "tr>td", text: state_change1.approver.to_s, count: 1
    assert_select "tr>td", text: state_change2.approver.to_s, count: 1
    assert_select "tr>td", text: state_change2.request.to_s, count: 1
    assert_select "tr>td", text: state_change2.request.to_s, count: 1
    assert_select "tr>td", text: state_change2.action.to_s, count: 2
  end
end
