require "rails_helper"

RSpec.describe "state_changes/show", type: :view do
  let(:state_change) { FactoryBot.create(:state_change) }
  before do
    assign(:state_change, state_change)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to include(state_change.approver.to_s)
    expect(rendered).to include(state_change.request.to_s)
    expect(rendered).to include(state_change.action.to_s)
  end
end
