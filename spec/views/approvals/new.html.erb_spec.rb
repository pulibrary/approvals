require "rails_helper"

RSpec.describe "approvals/new", type: :view do
  before do
    assign(:approval, Approval.new(
                        approver: nil,
                        request: nil,
                        approved: false
    ))
  end

  it "renders new approval form" do
    render

    assert_select "form[action=?][method=?]", approvals_path, "post" do
      assert_select "input[name=?]", "approval[approver_id]"

      assert_select "input[name=?]", "approval[request_id]"

      assert_select "input[name=?]", "approval[approved]"
    end
  end
end
