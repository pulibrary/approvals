require "rails_helper"

RSpec.describe "approvals/edit", type: :view do
  let(:approval) { FactoryBot.create(:approval) }
  before do
    assign(:approval, approval)
  end

  it "renders the edit approval form" do
    render

    assert_select "form[action=?][method=?]", approval_path(approval), "post" do
      assert_select "input[name=?]", "approval[approver_id]"

      assert_select "input[name=?]", "approval[request_id]"

      assert_select "input[name=?]", "approval[approved]"
    end
  end
end
