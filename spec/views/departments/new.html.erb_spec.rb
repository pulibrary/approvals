require "rails_helper"

RSpec.describe "departments/new", type: :view do
  before do
    assign(:department, Department.new(
                          name: "MyString",
                          head_id: 1,
                          admin_assistant_id: 1
    ))
  end

  it "renders new department form" do
    render

    assert_select "form[action=?][method=?]", departments_path, "post" do
      assert_select "input[name=?]", "department[name]"

      assert_select "input[name=?]", "department[head_id]"

      assert_select "input[name=?]", "department[admin_assistant_id]"
    end
  end
end
