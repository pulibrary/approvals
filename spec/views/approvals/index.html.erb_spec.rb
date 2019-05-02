require "rails_helper"

RSpec.describe "approvals/index", type: :view do
  let(:approval1) { FactoryBot.create(:approval) }
  let(:approval2) { FactoryBot.create(:approval) }
  before do
    assign(:approvals, [approval1, approval2])
  end

  it "renders a list of approvals" do
    render
    assert_select "tr>td", text: approval1.approver.to_s, count: 1
    assert_select "tr>td", text: approval2.approver.to_s, count: 1
    assert_select "tr>td", text: approval2.request.to_s, count: 1
    assert_select "tr>td", text: approval2.request.to_s, count: 1
    assert_select "tr>td", text: false.to_s, count: 2
  end
end
