require "rails_helper"

RSpec.describe "approvals/edit", type: :view do
  let(:approval) { FactoryBot.create(:approval) }
  before do
    assign(:approval, approval)
  end

  it "renders the edit approval form" do
    render

    assert_select "form[action=?][method=?]", approval_path(approval), "post" do
      assert_select "input[name=?][value=?]", "approval[approver_id]", approval.approver_id.to_s

      assert_select "input[name=?][value=?]", "approval[request_id]", approval.request_id.to_s

      assert_select "input[name=?][value=?]", "approval[approved]", approval.approved ? "1" : "0"
    end
  end
end
