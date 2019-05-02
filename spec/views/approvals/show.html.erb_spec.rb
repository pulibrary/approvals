require "rails_helper"

RSpec.describe "approvals/show", type: :view do
  let(:approval) { FactoryBot.create(:approval) }
  before do
    assign(:approval, approval)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to include(approval.approver.to_s)
    expect(rendered).to include(approval.request.to_s)
    expect(rendered).to match(/false/)
  end
end
